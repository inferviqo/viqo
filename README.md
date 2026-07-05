# Viqo

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square) [![npm]](https://www.npmjs.com/package/@inferviqo/viqo)

[npm]: https://img.shields.io/npm/v/@inferviqo/viqo.svg?style=flat-square

Viqo is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows — all through natural language commands. Use it in your terminal, IDE, or tag @viqo on GitHub.

**Learn more in the [official documentation](https://github.com/inferviqo/viqo).**

<img src="./demo.gif" />

## Get started

> [!NOTE]
> Installation via npm is deprecated. Use one of the recommended methods below.

For more installation options, uninstall steps, and troubleshooting, see the [setup documentation](https://github.com/inferviqo/viqo).

1. Install Viqo:

    **MacOS/Linux (Recommended):**
    ```bash
    curl -fsSL https://inferviqo.com/viqo/install.sh | bash
    ```

    **Homebrew (MacOS/Linux):**
    ```bash
    brew install --cask viqo
    ```

    **Windows (Recommended):**
    ```powershell
    irm https://inferviqo.com/viqo/install.ps1 | iex
    ```

    **WinGet (Windows):**
    ```powershell
    winget install Inferviqo.Viqo
    ```

    **NPM (Deprecated):**
    ```bash
    npm install -g @inferviqo/viqo
    ```

2. Navigate to your project directory and run `viqo`.

## Plugins

This repository includes several Viqo plugins that extend functionality with custom commands and agents. See the [plugins directory](./plugins/README.md) for detailed documentation on available plugins.

## Reporting Bugs

We welcome your feedback. Use the `/bug` command to report issues directly within Viqo, or file a [GitHub issue](https://github.com/inferviqo/viqo/issues).

## Community

Join [GitHub Discussions](https://github.com/inferviqo/viqo/discussions) to connect with other developers using Viqo. Get help, share feedback, and discuss your projects with the community.

## Data collection, usage, and retention

When you use Viqo, we collect feedback, which includes usage data (such as code acceptance or rejections), associated conversation data, and user feedback submitted via the `/bug` command.

### How we use your data

See our [data usage policies](https://github.com/inferviqo/viqo).

### Privacy safeguards

We have implemented several safeguards to protect your data, including limited retention periods for sensitive information, restricted access to user session data, and clear policies against using feedback for model training without consent.

For full details, please review our [License](./LICENSE.md).
