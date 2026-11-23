# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

This is a fork of [digininja/DVWA](https://github.com/digininja/DVWA) (Damn Vulnerable Web Application). The fork's goal is a **context-root aware** version that works behind reverse proxies, packaged as a container image (`sccp-dvwa`) configured through environment variables. The original upstream README is `README.en.md`. `README.md` covers this fork.

### Background

- The codebase is based on an **older snapshot of the official DVWA**, not the current upstream. Do not assume upstream's current structure or features exist here.
- It is containerized with **Kubernetes deployment for student activities** in mind (hence env-var configuration, external MySQL, context-root support, and the `kubernetes/` manifests).
- The codebase is being **updated to keep up with newer PHP versions** (currently `php:8.5-apache`). Fixing deprecations/incompatibilities in the old code is an expected kind of change.

The application is **intentionally vulnerable**. Do not "fix" vulnerabilities in `vulnerabilities/*/source/{low,medium,high}.php`, because they exist on purpose. Only `impossible.php` is meant to be secure.

## Commands

The Makefile uses `podman` (`DOCKER_CMD`). The image tag comes from `DOCKER_IMAGE_VERSION` (format `YYYYMMDD.HHMM`), which is bumped in a dedicated commit for each release.

```sh
make docker-mysql-run     # start a MySQL 8 container (dvwa-mysql) on :3306
make docker-build         # build sccp-dvwa:latest
make docker-run           # run on :8080 (edit DVWA_DB_SERVER in Makefile to point at the DB host)
make docker-build-prod    # build sccp-dvwa:$(DOCKER_IMAGE_VERSION) with --no-cache
make docker-tag && make docker-push   # push to $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)
```

Tests (run from the repo root): `python3 -m pytest -s`. The only test is `tests/test_url.py`, which checks that external URLs found in PHP files are still alive. It needs network access.

Kubernetes manifests are in `kubernetes/`. Run `make setup-secrets` there before applying `0[01245]*.yaml`.

## Architecture

- **Runtime configuration via sed placeholders**: `docker/config.inc.php.dist` is copied to `config/config.inc.php` at build time. It contains placeholders such as `_DVWA_DB_SERVER_` and `_DVWA_WEB_CONTEXTROOT_`. At container start, `docker/run.sh` rewrites those placeholders from the `DVWA_*` env vars. It also replaces `_DVWA_ADMIN_PASSWORD_` in `dvwa/includes/DBMS/MySQL.php`, which seeds the admin user during DB setup. New configurable values must follow the same pattern: placeholder + `run.sh` sed + `ENV` default in `Dockerfile` + README.
- **Context root**: `$_DVWA['web_contextroot']` is prefixed to absolute redirects and asset URLs (`dvwaRedirect(...)` in `login.php`, `setup.php`, `security.php`, and `dvwa/includes/dvwaPage.inc.php`). Any new redirect or absolute link should be prefixed the same way.
- **Page framework**: Every page defines `DVWA_WEB_PAGE_TO_ROOT` (a relative path to the repo root) and then requires `dvwa/includes/dvwaPage.inc.php`. That file provides session/auth (`dvwaPageStartup`), security level (`dvwaSecurityLevelGet`), DB connection (`dvwaDatabaseConnect`), and HTML rendering (`dvwaPageNewGrab` / `dvwaHtmlEcho`).
- **Vulnerability modules**: Each `vulnerabilities/<name>/index.php` selects `source/{low,medium,high,impossible}.php` based on the current security level. `help/` holds the help text. `view_source*.php` displays the source files.
- **Database**: The container is set up for MySQL (`$DBMS = 'MySQL'`) and needs an external DB. Use MySQL 8.x, not 9.x, because DVWA relies on the `MD5()` SQL function.
- **Dockerfile**: This is a multi-stage build on `php:8.5-alpine`. The `builder` stage compiles `gd`/`mysqli`/`pdo_mysql` with `-dev` packages. The runtime stage installs only the shared libraries (Alpine package names, e.g. `libpng`, `libjpeg-turbo`) and copies `/usr/local/lib/php/extensions/` and `/usr/local/etc/php/conf.d/` from the builder. If you add a PHP extension, add its `-dev` package to the builder and its runtime library to the final stage.
- **Web server**: The Alpine PHP image has no mod_php. Apache from Alpine packages (`apache2`, `apache-mod-fcgid`) runs PHP through the image's `/usr/local/bin/php-cgi` via mod_fcgid. `docker/httpd-dvwa.conf` replaces `/etc/apache2/conf.d/mod_fcgid.conf`. The Dockerfile also uses `sed` on `httpd.conf` to set `User`/`Group` to `www-data`, DocumentRoot to `/var/www/html`, and logs to stdout/stderr. `docker/run.sh` is POSIX `sh` (there is no bash) and starts `httpd -D FOREGROUND`. No `php.ini` is loaded; the repo-root `php.ini` is not applied.
- The command-injection module needs `ping`, which requires the `NET_RAW` capability. Rootless podman does not grant it by default, so ping fails there regardless of the image. Kubernetes' restricted policy drops it too. `vulnerabilities/exec/index.php` shows a warning box stating this.
- PHP 8.4/8.5 deprecation warnings have been fixed in the codebase, so keep new code free of them.
