# CI pipeline for VanSpots
#
# Run the full pipeline locally with:
#
#   bin/ci
#
# The pipeline runs each step sequentially and halts on the first failure,
# printing a summary of passed/failed steps at the end.
#
# Stages:
#   1. Setup      Install dependencies, prepare the database
#   2. Lint       Code style, autoloading
#   3. Security   Static analysis, dependency audits
#   4. Assets     Sass + PostCSS compilation
#   5. Test       Unit, integration, system
#
# These steps mirror the GitHub Actions CI workflow (.github/workflows/ci.yml)
# but run everything in a single local process for fast pre-push verification.

CI.run do
  # ── 1. Setup ──────────────────────────────────────────────────────
  # Bundle install (if needed) and run db:prepare to apply any pending
  # migrations. Skips starting the dev server.
  step "Setup: Dependencies and database",
       "bin/setup --skip-server"

  # ── 2. Lint ───────────────────────────────────────────────────────
  # RuboCop enforces the Rails Omakase style guide (.rubocop.yml).
  step "Lint: Ruby (RuboCop)",
       "bin/rubocop"

  # Verify that all autoloaded constants follow Zeitwerk's naming
  # conventions and that eager loading won't blow up in production.
  step "Lint: Zeitwerk autoloading check",
       "bin/rails zeitwerk:check"

  # ── 3. Security ───────────────────────────────────────────────────
  # Brakeman performs static analysis for common Rails security issues
  # (SQL injection, XSS, mass assignment, etc.). Exits non-zero on
  # any warning or error. See config/brakeman.ignore for false positives.
  step "Security: Static analysis (Brakeman)",
       "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"

  # Scan import-mapped JS packages for known vulnerabilities.
  step "Security: JS vulnerabilities (importmap audit)",
       "bin/importmap audit"

  # ── 4. Assets ─────────────────────────────────────────────────────
  # Compile Sass to CSS and run Autoprefixer via PostCSS to verify
  # the full CSS build pipeline succeeds.
  step "Assets: Compile CSS (Sass + PostCSS)",
       "yarn build:css"

  # ── 5. Test ───────────────────────────────────────────────────────
  # Run the full Minitest suite (models, controllers, integration)
  # with parallel workers.
  step "Test: Unit and integration",
       "bin/rails test"

  # Run Capybara system tests with headless Chrome via Selenium.
  step "Test: System (browser)",
       "bin/rails test:system"
end
