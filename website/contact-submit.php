<?php
/**
 * Groeiwijze Contact Form Handler
 *
 * Handles POST submissions from contact.html, validates input,
 * applies anti-spam measures, and sends email via PHPMailer.
 */

declare(strict_types=1);

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

define('DEBUG_MODE', false);

const SUFFIX_REGEX = '/^[a-zA-Z0-9_-]{1,100}$/';

define('CONFIG_PATH', dirname($_SERVER['DOCUMENT_ROOT']) . '/private/contact-mail.config.php');
define('AUTOLOAD_PATH', dirname(__DIR__) . '/vendor/autoload.php');
define('RATELIMIT_DIR', dirname($_SERVER['DOCUMENT_ROOT']) . '/private/ratelimit');

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * @throws never (exits)
 */
function showError(string $message): void
{
    http_response_code(400);
    $contactLink = appendWtQuery('contact.html', extractWtSuffix());
    ?>
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fout - Groeiwijze</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Libre+Franklin:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="assets/img/favicon.svg" type="image/svg+xml">
    <link rel="stylesheet" href="css/style.css?v=11">
</head>
<body>
    <a class="skip-link" href="#main">Direct naar inhoud</a>
    <header class="header">
        <div class="container">
            <div class="header__inner">
                <a href="index.html" class="logo">
                    <svg class="logo__icon" viewBox="0 0 70 76" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M0 76V23C0 10.297 10.297 0 23 0h26c11.598 0 21 9.402 21 21v55H56V23c0-4.97-4.03-9-9-9H24c-5.523 0-10 4.477-10 10v52H0Z" fill="currentColor"/>
                    </svg>
                    <div class="logo__text">
                        <span class="logo__name">groeiwijze</span>
                        <span class="logo__tagline">praktijk voor herstel en groei</span>
                    </div>
                </a>
            </div>
        </div>
    </header>

    <main id="main">
    <section class="section">
        <div class="container container--narrow text-center">
            <h1>Er ging iets mis</h1>
            <p class="lead mt-md"><?= nl2br(htmlspecialchars($message, ENT_QUOTES, 'UTF-8')) ?></p>
            <p class="mt-lg">
                <a href="<?= htmlspecialchars($contactLink, ENT_QUOTES, 'UTF-8') ?>" class="btn btn--primary">Terug naar contactformulier</a>
            </p>
        </div>
    </section>

    </main>

    <footer class="footer">
        <div class="container">
            <div class="footer__bottom">
                <p>&copy; <?= date('Y') ?> Groeiwijze</p>
            </div>
        </div>
    </footer>
</body>
</html>
    <?php
    exit;
}

/**
 * @throws never (exits)
 */
function redirectSuccess(): void
{
    $location = appendWtQuery('thank-you.html', extractWtSuffix());
    header('Location: ' . $location, true, 303);
    exit;
}

function extractWtSuffix(): string
{
    $candidates = [
        $_POST['wt'] ?? null,
        $_GET['wt'] ?? null,
        extractWtFromReferer(),
    ];

    foreach ($candidates as $candidate) {
        if (is_string($candidate) && preg_match(SUFFIX_REGEX, $candidate) === 1) {
            return $candidate;
        }
    }

    return '';
}

function extractWtFromReferer(): ?string
{
    $referer = $_SERVER['HTTP_REFERER'] ?? '';
    if ($referer === '') {
        return null;
    }

    $query = parse_url($referer, PHP_URL_QUERY);
    if (!is_string($query) || $query === '') {
        return null;
    }

    parse_str($query, $params);
    $wt = $params['wt'] ?? null;

    return is_string($wt) ? $wt : null;
}

function appendWtQuery(string $url, string $wtSuffix): string
{
    if ($wtSuffix === '') {
        return $url;
    }

    return $url . '?wt=' . urlencode($wtSuffix);
}

function sanitizeInput(string $input, int $maxLength): string
{
    $input = str_replace("\0", '', $input);
    $input = str_replace(["\r\n", "\r"], "\n", $input);
    $input = trim($input);

    if (mb_strlen($input) > $maxLength)
        $input = mb_substr($input, 0, $maxLength);

    return $input;
}

function hasHeaderInjection(string $input): bool
{
    return preg_match('/[\r\n]/', $input) === 1;
}

/**
 * @throws Exception
 */
function createMailer(array $config): PHPMailer
{
    $mailer = new PHPMailer(true);
    $mailer->isSMTP();
    $mailer->Host = $config['smtp_host'];
    $mailer->SMTPAuth = true;
    $mailer->Username = $config['smtp_user'];
    $mailer->Password = $config['smtp_pass'];
    $mailer->SMTPSecure = $config['smtp_secure'] ?? PHPMailer::ENCRYPTION_STARTTLS;
    $mailer->Port = $config['smtp_port'];
    $mailer->CharSet = 'UTF-8';
    $mailer->setFrom($config['mail_from'], $config['mail_from_name']);

    return $mailer;
}

// ============================================================================
// BOOTSTRAP
// ============================================================================

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    header('Allow: POST');
    die('Method Not Allowed');
}

if (!file_exists(CONFIG_PATH)) {
    error_log('Groeiwijze contact: Config file not found at: ' . CONFIG_PATH);
    showError(DEBUG_MODE ? 'Config file not found at: ' . CONFIG_PATH : 'Er is een technische fout opgetreden. Probeer het later opnieuw.');
}
$config = require CONFIG_PATH;

if (!file_exists(AUTOLOAD_PATH)) {
    error_log('Groeiwijze contact: Composer autoload not found at: ' . AUTOLOAD_PATH);
    showError(DEBUG_MODE ? 'Composer autoload not found at: ' . AUTOLOAD_PATH : 'Er is een technische fout opgetreden. Probeer het later opnieuw.');
}
require AUTOLOAD_PATH;

date_default_timezone_set('Europe/Amsterdam');

// ============================================================================
// ANTI-SPAM CHECKS
// ============================================================================

$honeypot = trim($_POST['website'] ?? '');
if ($honeypot !== '')
    redirectSuccess();

$formStartedAt = (int) ($_POST['form_started_at'] ?? 0);
$now = time();
if ($formStartedAt <= 0 || ($now - $formStartedAt) < 3)
    redirectSuccess();

$visitorIp = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$ipHash = hash('sha256', $visitorIp . ($config['rate_limit_salt'] ?? 'groeiwijze'));

if (!is_dir(RATELIMIT_DIR))
    @mkdir(RATELIMIT_DIR, 0750, true);

$rateLimitFile = RATELIMIT_DIR . '/' . $ipHash . '.json';
$maxSubmissions = 5;
$timeWindow = 3600;

if (file_exists($rateLimitFile)) {
    $rateData = json_decode(file_get_contents($rateLimitFile), true);
    if (!is_array($rateData))
        $rateData = ['timestamps' => []];

    $rateData['timestamps'] = array_filter(
        $rateData['timestamps'] ?? [],
        fn($ts) => ($now - $ts) < $timeWindow
    );

    if (count($rateData['timestamps']) >= $maxSubmissions)
        showError('Je hebt te veel berichten verstuurd. Probeer het over een uur opnieuw.');
} else {
    $rateData = ['timestamps' => []];
}

// ============================================================================
// INPUT VALIDATION
// ============================================================================

$errors = [];

$name = sanitizeInput($_POST['name'] ?? '', 120);
if ($name === '')
    $errors[] = 'Vul je naam in.';
elseif (hasHeaderInjection($name))
    $errors[] = 'Ongeldige tekens in naam.';

$email = sanitizeInput($_POST['email'] ?? '', 254);
if ($email === '')
    $errors[] = 'Vul je e-mailadres in.';
elseif (!filter_var($email, FILTER_VALIDATE_EMAIL))
    $errors[] = 'Vul een geldig e-mailadres in.';
elseif (hasHeaderInjection($email))
    $errors[] = 'Ongeldige tekens in e-mailadres.';

$phone = sanitizeInput($_POST['phone'] ?? '', 40);
if ($phone !== '' && !preg_match('/^[0-9\s\+\-\(\)]+$/', $phone))
    $errors[] = 'Ongeldig telefoonnummer.';

$message = sanitizeInput($_POST['message'] ?? '', 5000);

if (!empty($errors))
    showError(implode("\n", $errors));

// ============================================================================
// UPDATE RATE LIMIT
// ============================================================================

$rateData['timestamps'][] = $now;
file_put_contents($rateLimitFile, json_encode($rateData), LOCK_EX);
@chmod($rateLimitFile, 0640);

// ============================================================================
// PREPARE EMAIL CONTENT
// ============================================================================

$timestamp = date('d-m-Y H:i:s');
$referer = $_SERVER['HTTP_REFERER'] ?? 'Onbekend';

$subjectToAnja = '[Groeiwijze contact] Nieuw bericht van ' . $name;
$bodyToAnja = <<<EOT
Nieuw contactformulier bericht via groeiwijze.nl

----------------------------------------
Naam:         {$name}
E-mail:       {$email}
Telefoon:     {$phone}
----------------------------------------

Bericht:
{$message}

----------------------------------------
Verzonden op: {$timestamp}
IP-adres:     {$visitorIp}
Pagina:       {$referer}
----------------------------------------
EOT;

$subjectToVisitor = 'Bedankt voor je bericht - Groeiwijze';
$bodyToVisitor = <<<EOT
Beste {$name},

Bedankt voor je bericht via groeiwijze.nl.

Ik heb je bericht ontvangen en neem zo snel mogelijk contact met je op.

Met vriendelijke groet,
Anja
Groeiwijze - Praktijk voor herstel en groei

---
Dit is een automatisch verzonden bevestiging.
EOT;

// ============================================================================
// SEND EMAILS
// ============================================================================

try {
    $mailToAnja = createMailer($config);
    $mailToAnja->addReplyTo($email, $name);
    $mailToAnja->addAddress($config['mail_to']);
    $mailToAnja->Subject = $subjectToAnja;
    $mailToAnja->Body = $bodyToAnja;
    $mailToAnja->send();

    $mailToVisitor = createMailer($config);
    $mailToVisitor->addAddress($email, $name);
    $mailToVisitor->Subject = $subjectToVisitor;
    $mailToVisitor->Body = $bodyToVisitor;
    $mailToVisitor->send();
} catch (Exception $e) {
    error_log('Groeiwijze contact mail error: ' . $e->getMessage());
    showError(DEBUG_MODE ? 'Mail error: ' . $e->getMessage() : 'Er is een fout opgetreden bij het versturen. Probeer het later opnieuw of mail direct naar info@groeiwijze.nl.');
}

redirectSuccess();
