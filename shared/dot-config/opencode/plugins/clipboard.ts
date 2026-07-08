import { execSync } from "node:child_process"

import type { Plugin } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin/tool"

export const ClipboardPlugin: Plugin = async () => {
  return {
    tool: {
      clipboard: tool({
        description:
          "Copy text to the system clipboard. Uses wl-copy (Wayland) locally, " +
          "and falls back to tmux (OSC 52) so it also works inside an SSH session. " +
          "Use this when the user asks you to copy something to their clipboard.",
        args: {
          text: tool.schema.string().describe("The text to copy to the clipboard"),
        },
        async execute(args) {
          const text = args.text
          const attempts: Array<[string, () => void]> = []

          if (process.env.WAYLAND_DISPLAY) {
            attempts.push(["wl-copy", () => execSync("wl-copy", { input: text })])
          }
          if (process.env.TMUX) {
            attempts.push(["tmux (OSC52)", () => {
              const clients = execSync("tmux list-clients -F '#{client_name}'")
                .toString().trim().split("\n").filter(Boolean)
              for (const client of clients) {
                try {
                  execSync(`tmux load-buffer -w -t ${client} -`, { input: text })
                } catch {}
              }
            }])
          }

          for (const [name, fn] of attempts) {
            try {
              fn()
              return `Copied to clipboard via ${name} (${text.length} characters)`
            } catch {
              // try the next backend
            }
          }

          return "Failed to copy to clipboard: no Wayland display or tmux session available"
        },
      }),
    },
  }
}
