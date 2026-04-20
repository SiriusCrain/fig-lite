export default {
  "*.{rs,toml}": () => [
    "cargo +nightly fmt --check -- --color always",
    "cargo clippy --locked --color always -- -D warnings",
  ],
  "*.proto": () => [
    "sh -c 'cd proto && pnpm exec buf lint && pnpm exec buf format --exit-code > /dev/null'",
  ],
  "*.py": ["ruff format --check", "ruff check"],
  "*.{ts,js,tsx,jsx,mjs}": "prettier --check",
  "!(*test*)*": "typos --config .typos.toml",
};
