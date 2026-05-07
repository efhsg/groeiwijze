<?php

declare(strict_types=1);

/**
 * Dev-only worktree-lijst endpoint.
 *
 * Scant /var/www/projects op directories `groeiwijze.nl-<suffix>`, valideert elke
 * suffix tegen dezelfde whitelist als nginx en de switcher, en emit een
 * alfabetisch gesorteerde JSON-array van suffix-strings. Geen paden,
 * branchmetadata of `.git`-details verlaten dit endpoint.
 */

const PROJECTS_ROOT = '/var/www/projects';
const PROJECT_PREFIX = 'groeiwijze.nl-';
const SUFFIX_REGEX = '/^[a-zA-Z0-9_-]{1,100}$/';

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('Cache-Control: no-store');

$projectsRoot = realpath(PROJECTS_ROOT);
if ($projectsRoot === false || !is_dir($projectsRoot)) {
    error_log('wt-list: projects-root onbeschikbaar');
    echo json_encode([], JSON_UNESCAPED_SLASHES);
    return;
}

$entries = @scandir($projectsRoot);
if ($entries === false) {
    error_log('wt-list: scandir projects-root mislukt');
    echo json_encode([], JSON_UNESCAPED_SLASHES);
    return;
}

$suffixes = [];
$prefixLength = strlen(PROJECT_PREFIX);

foreach ($entries as $entry) {
    if ($entry === '.' || $entry === '..') {
        continue;
    }

    if (strncmp($entry, PROJECT_PREFIX, $prefixLength) !== 0) {
        continue;
    }

    $suffix = substr($entry, $prefixLength);
    if ($suffix === '' || preg_match(SUFFIX_REGEX, $suffix) !== 1) {
        error_log('wt-list: suffix afgewezen — invalid');
        continue;
    }

    $candidatePath = $projectsRoot . DIRECTORY_SEPARATOR . $entry;
    $resolved = realpath($candidatePath);
    if ($resolved === false || !is_dir($resolved)) {
        error_log('wt-list: suffix afgewezen — path niet resolvebaar');
        continue;
    }

    if (strncmp($resolved, $projectsRoot . DIRECTORY_SEPARATOR, strlen($projectsRoot) + 1) !== 0) {
        error_log('wt-list: suffix afgewezen — buiten projects-root');
        continue;
    }

    if (!is_dir($resolved . DIRECTORY_SEPARATOR . 'website')) {
        error_log('wt-list: suffix afgewezen — geen website-directory');
        continue;
    }

    if (!file_exists($resolved . DIRECTORY_SEPARATOR . '.git')) {
        error_log('wt-list: suffix afgewezen — geen .git');
        continue;
    }

    $suffixes[] = $suffix;
}

sort($suffixes, SORT_STRING);

echo json_encode($suffixes, JSON_UNESCAPED_SLASHES);
