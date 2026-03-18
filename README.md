# Developer Kit - Copilot CLI Compatible

This is a restructured version of [Giuseppe Trisciuoglio's Developer Kit Core](https://github.com/giuseppe-trisciuoglio/developer-kit) plugin, adapted to work with both **Claude Code** and **GitHub Copilot CLI** following [Ken Muse's plugin format](https://www.kenmuse.com/blog/creating-agent-plugins-for-vs-code-and-copilot-cli).

## Installation

### Claude Code
```bash
claude plugin install developer-kit-core@developer-kit-copilot
```

### GitHub Copilot CLI
```bash
copilot plugin install developer-kit-core@developer-kit-copilot
```

### VS Code
Enable `chat.plugins.enabled` in settings, then search for `@agentPlugins developer-kit`.

## Structure

```
├── .github/plugin/marketplace.json     # Marketplace discovery
└── plugins/developer-kit-core/
    ├── .github/plugin.json             # Copilot-compatible manifest
    ├── .claude-plugin/plugin.json      # Claude Code manifest
    ├── agents/                         # 6 specialized agents
    ├── commands/                       # 20 workflow commands
    ├── skills/                         # 4 skills
    └── hooks/                          # Safety hooks
```

## Credits

- **Original Author**: Giuseppe Trisciuoglio
- **Original Repository**: https://github.com/giuseppe-trisciuoglio/developer-kit
- **License**: MIT
- **Plugin Format**: Based on [Ken Muse's blog post](https://www.kenmuse.com/blog/creating-agent-plugins-for-vs-code-and-copilot-cli)
