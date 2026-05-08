(function () {
    "use strict";

    if (document.querySelector('.wt-switcher')) {
        return;
    }

    var SUFFIX_REGEX = /^[a-zA-Z0-9_-]{1,100}$/;
    var FETCH_TIMEOUT_MS = 4000;
    var LIST_ENDPOINT = '/_wt/list.php';
    var QUERY_KEY = 'wt';
    var MAIN_LABEL = 'main';

    var STYLES = [
        '.wt-switcher{position:fixed;bottom:16px;right:16px;z-index:9000;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif;font-size:13px;line-height:1.4;color:#F8F9FA;}',
        '.wt-switcher *{box-sizing:border-box;}',
        '.wt-switcher__trigger{display:inline-flex;align-items:center;gap:6px;background:#212529;color:#F8F9FA;border:0;border-radius:999px;padding:8px 14px;cursor:pointer;max-width:220px;box-shadow:0 2px 6px rgba(0,0,0,0.25);}',
        '.wt-switcher__trigger:hover{background:linear-gradient(rgba(255,255,255,0.1),rgba(255,255,255,0.1)),#212529;}',
        '.wt-switcher__trigger:active{transform:translateY(1px);}',
        '.wt-switcher__trigger:focus-visible{outline:2px solid #0D6EFD;outline-offset:2px;}',
        '.wt-switcher__label{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:170px;}',
        '.wt-switcher--error .wt-switcher__trigger{background:#5A1F1F;}',
        '.wt-switcher--stale .wt-switcher__trigger{background:#5A4A1F;}',
        '.wt-switcher__panel{position:absolute;bottom:calc(100% + 8px);right:0;min-width:220px;max-width:320px;background:#212529;color:#F8F9FA;border-radius:12px;padding:8px 0;box-shadow:0 8px 24px rgba(0,0,0,0.35);display:none;}',
        '.wt-switcher--open .wt-switcher__panel{display:block;}',
        '.wt-switcher__status{padding:8px 14px;color:#F8F9FA;opacity:0.85;}',
        '.wt-switcher__list{list-style:none;margin:0;padding:0;max-height:50vh;overflow-y:auto;}',
        '.wt-switcher__item{margin:0;}',
        '.wt-switcher__option{display:flex;align-items:center;gap:8px;width:100%;background:transparent;border:0;color:#F8F9FA;text-align:left;padding:8px 14px;cursor:pointer;font:inherit;}',
        '.wt-switcher__option:hover{background:rgba(255,255,255,0.1);}',
        '.wt-switcher__option:active{transform:translateY(1px);}',
        '.wt-switcher__option:focus-visible{outline:2px solid #0D6EFD;outline-offset:-2px;}',
        '.wt-switcher__option[aria-current="page"]{color:#FFC107;}',
        '.wt-switcher__option[aria-current="page"]::before{content:"";display:inline-block;width:8px;height:8px;border-radius:50%;background:#FFC107;flex:0 0 auto;}',
        '.wt-switcher__option-label{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}',
        '@media (max-width:480px){',
        '  .wt-switcher__panel{position:fixed;bottom:0;left:0;right:0;width:100%;max-width:100%;border-radius:12px 12px 0 0;padding:12px 0 24px;}',
        '  .wt-switcher__list{max-height:60vh;}',
        '}'
    ].join('');

    var styleEl = document.createElement('style');
    styleEl.setAttribute('data-wt-switcher', '');
    styleEl.textContent = STYLES;
    document.head.appendChild(styleEl);

    var container = document.createElement('div');
    container.className = 'wt-switcher';
    container.setAttribute('aria-label', 'Worktree-switcher');

    var trigger = document.createElement('button');
    trigger.type = 'button';
    trigger.className = 'wt-switcher__trigger';
    trigger.setAttribute('aria-haspopup', 'true');
    trigger.setAttribute('aria-expanded', 'false');
    trigger.setAttribute('aria-controls', 'wt-switcher-panel');

    var triggerLabel = document.createElement('span');
    triggerLabel.className = 'wt-switcher__label';
    trigger.appendChild(triggerLabel);

    var panel = document.createElement('div');
    panel.className = 'wt-switcher__panel';
    panel.id = 'wt-switcher-panel';
    panel.setAttribute('role', 'menu');

    var status = document.createElement('div');
    status.className = 'wt-switcher__status';
    status.setAttribute('aria-live', 'polite');
    panel.appendChild(status);

    var list = document.createElement('ul');
    list.className = 'wt-switcher__list';
    list.setAttribute('role', 'none');
    panel.appendChild(list);

    container.appendChild(trigger);
    container.appendChild(panel);

    function readCurrentSuffix() {
        var raw = new URL(window.location.href).searchParams.get(QUERY_KEY);
        if (raw === null || raw === '') {
            return '';
        }
        return raw;
    }

    function setBadge(text, modifier) {
        triggerLabel.textContent = text;
        trigger.setAttribute('title', text);
        container.classList.remove('wt-switcher--error', 'wt-switcher--stale');
        if (modifier) {
            container.classList.add('wt-switcher--' + modifier);
        }
    }

    function setStatus(text) {
        status.textContent = text;
        status.style.display = text === '' ? 'none' : '';
    }

    function buildUrlForSuffix(suffix) {
        var url = new URL(window.location.href);
        if (suffix === '') {
            url.searchParams.delete(QUERY_KEY);
        } else {
            url.searchParams.set(QUERY_KEY, suffix);
        }
        return url.toString();
    }

    function hasActiveSuffix() {
        var suffix = readCurrentSuffix();
        return suffix !== '' && SUFFIX_REGEX.test(suffix);
    }

    function isSkippableHref(href) {
        if (!href || href.charAt(0) === '#') {
            return true;
        }

        var normalized = href.toLowerCase();
        return normalized.indexOf('javascript:') === 0
            || normalized.indexOf('mailto:') === 0
            || normalized.indexOf('tel:') === 0;
    }

    function sameOriginUrl(rawUrl) {
        try {
            var url = new URL(rawUrl, window.location.href);
            return url.origin === window.location.origin ? url : null;
        } catch (error) {
            return null;
        }
    }

    function ensureHiddenWtInput(form, suffix) {
        var existing = form.querySelector('input[name="' + QUERY_KEY + '"]');
        if (existing) {
            return;
        }

        var input = document.createElement('input');
        input.type = 'hidden';
        input.name = QUERY_KEY;
        input.value = suffix;
        form.appendChild(input);
    }

    function makeWorktreeSticky() {
        if (!hasActiveSuffix()) {
            return;
        }

        document.addEventListener('click', function (event) {
            var suffix = readCurrentSuffix();
            if (suffix === '' || !SUFFIX_REGEX.test(suffix)) {
                return;
            }

            var target = event.target;
            var link = target && target.closest ? target.closest('a[href]') : null;
            if (!link) {
                return;
            }

            var href = link.getAttribute('href');
            if (isSkippableHref(href)) {
                return;
            }

            var url = sameOriginUrl(href);
            if (!url || url.searchParams.has(QUERY_KEY)) {
                return;
            }

            url.searchParams.set(QUERY_KEY, suffix);
            link.setAttribute('href', url.pathname + url.search + url.hash);
        }, true);

        document.addEventListener('submit', function (event) {
            var suffix = readCurrentSuffix();
            if (suffix === '' || !SUFFIX_REGEX.test(suffix)) {
                return;
            }

            var form = event.target;
            if (!form || form.tagName !== 'FORM') {
                return;
            }

            var action = form.getAttribute('action') || window.location.href;
            var url = sameOriginUrl(action);
            if (!url || url.searchParams.has(QUERY_KEY)) {
                return;
            }

            if ((form.getAttribute('method') || 'get').toLowerCase() === 'get') {
                ensureHiddenWtInput(form, suffix);
                return;
            }

            url.searchParams.set(QUERY_KEY, suffix);
            form.setAttribute('action', url.pathname + url.search + url.hash);
        }, true);
    }

    function renderOptions(suffixes, currentSuffix) {
        list.textContent = '';

        var items = [{ value: '', label: MAIN_LABEL }];
        for (var i = 0; i < suffixes.length; i++) {
            items.push({ value: suffixes[i], label: suffixes[i] });
        }

        items.forEach(function (entry) {
            var li = document.createElement('li');
            li.className = 'wt-switcher__item';
            li.setAttribute('role', 'none');

            var option = document.createElement('button');
            option.type = 'button';
            option.className = 'wt-switcher__option';
            option.setAttribute('role', 'menuitem');
            option.setAttribute('data-suffix', entry.value);

            var labelSpan = document.createElement('span');
            labelSpan.className = 'wt-switcher__option-label';
            labelSpan.textContent = entry.label;
            option.appendChild(labelSpan);
            option.setAttribute('title', entry.label);

            if (entry.value === currentSuffix) {
                option.setAttribute('aria-current', 'page');
            }

            option.addEventListener('click', function () {
                if (entry.value !== '' && !SUFFIX_REGEX.test(entry.value)) {
                    return;
                }
                window.location.href = buildUrlForSuffix(entry.value);
            });

            li.appendChild(option);
            list.appendChild(li);
        });
    }

    function applyState(suffixes) {
        var current = readCurrentSuffix();

        if (current === '') {
            setBadge(MAIN_LABEL, null);
            setStatus('');
            renderOptions(suffixes, '');
            return;
        }

        var available = false;
        for (var i = 0; i < suffixes.length; i++) {
            if (suffixes[i] === current) {
                available = true;
                break;
            }
        }

        if (!SUFFIX_REGEX.test(current)) {
            setBadge(MAIN_LABEL, 'stale');
            setStatus('Ongeldige worktree-suffix in URL — main wordt getoond.');
            renderOptions(suffixes, '');
            return;
        }

        if (!available) {
            setBadge(current + ' (stale)', 'stale');
            setStatus('Worktree "' + current + '" niet beschikbaar — main wordt getoond.');
            renderOptions(suffixes, '');
            return;
        }

        setBadge(current, null);
        setStatus('');
        renderOptions(suffixes, current);
    }

    function applyError() {
        setBadge('⚠ ?', 'error');
        setStatus('Kon worktrees niet ophalen — refresh om opnieuw te proberen.');
        list.textContent = '';
    }

    function applyLoading() {
        setBadge('…', null);
        setStatus('Worktrees ophalen…');
    }

    function fetchSuffixes() {
        var controller = new AbortController();
        var timer = window.setTimeout(function () { controller.abort(); }, FETCH_TIMEOUT_MS);

        return window.fetch(LIST_ENDPOINT, {
            method: 'GET',
            credentials: 'same-origin',
            headers: { 'Accept': 'application/json' },
            signal: controller.signal,
            cache: 'no-store'
        }).then(function (response) {
            window.clearTimeout(timer);
            if (!response.ok) {
                throw new Error('http_' + response.status);
            }
            return response.json();
        }).then(function (data) {
            if (!Array.isArray(data)) {
                throw new Error('malformed_payload');
            }
            var clean = [];
            for (var i = 0; i < data.length; i++) {
                if (typeof data[i] === 'string' && SUFFIX_REGEX.test(data[i])) {
                    clean.push(data[i]);
                }
            }
            return clean;
        }).catch(function (err) {
            window.clearTimeout(timer);
            throw err;
        });
    }

    function openPanel() {
        container.classList.add('wt-switcher--open');
        trigger.setAttribute('aria-expanded', 'true');
    }

    function closePanel(returnFocus) {
        if (!container.classList.contains('wt-switcher--open')) {
            return;
        }
        container.classList.remove('wt-switcher--open');
        trigger.setAttribute('aria-expanded', 'false');
        if (returnFocus) {
            trigger.focus();
        }
    }

    function togglePanel() {
        if (container.classList.contains('wt-switcher--open')) {
            closePanel(true);
        } else {
            openPanel();
        }
    }

    trigger.addEventListener('click', function (event) {
        event.stopPropagation();
        togglePanel();
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && container.classList.contains('wt-switcher--open')) {
            closePanel(true);
        }
    });

    document.addEventListener('click', function (event) {
        if (!container.contains(event.target)) {
            closePanel(false);
        }
    });

    document.body.appendChild(container);

    makeWorktreeSticky();

    applyLoading();
    fetchSuffixes()
        .then(function (suffixes) { applyState(suffixes); })
        .catch(function () { applyError(); });
}());
