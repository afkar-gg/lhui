-- Linkhive update feed.
--
-- The hub's Updates tab fetches this file at runtime from
--   https://raw.githubusercontent.com/afkar-gg/lhui/refs/heads/main/ui/Linkhive_Updates.luau
-- reads it as raw text, and turns it into a table. Two shapes are accepted:
--
--   1. A Luau chunk that returns a table -- this file. It is executed through
--      the executor's loadstring, so it may use real Luau syntax.
--   2. Raw JSON text. The hub falls back to HttpService:JSONDecode when the
--      chunk does not load, so a pure-JSON feed works too:
--
--        { "Version": "3.4.0", "Released": "2026-02-14", "Changes": [ ... ] }
--
-- Contract
--   Version   string    shown as "Version <value>"
--   Released  string?   optional, appended to the version line
--   Changes   table     list; each entry is either
--                         - a string, or
--                         - a table { Type = "...", Text = "..." }
--                       "Type" is rendered in brackets, e.g. "[Added] ...".
--
-- Editing this file is the whole release process: bump Version, prepend a
-- Change entry. Every client picks it up on the next Updates tab visit.

return {
	Version = "3.4.0",
	Released = "2026-02-14",
	Changes = {
		{
			Type = "Added",
			Text = "Home tab: greeting, account summary, live field egg stats and a one-click refresh.",
		},
		{
			Type = "Added",
			Text = "Developer tab listing the team and their roles.",
		},
		{
			Type = "Added",
			Text = "Webhook tab: post steal results to a Discord webhook, with per-event toggles and a test button.",
		},
		{
			Type = "Added",
			Text = "Updates tab, reading this feed so the changelog ships without a client update.",
		},
		{
			Type = "Changed",
			Text = "The Predictor tab is gone; the Webhook tab took its place.",
		},
		{
			Type = "Changed",
			Text = "The Events tab is parked behind a Coming Soon notice while its tools are rebuilt.",
		},
		{
			Type = "Improved",
			Text = "Dead code removed and hot loops trimmed, for a lighter run under obfuscation.",
		},
		{
			Type = "Fixed",
			Text = "The Steal Panel opens on every execution again instead of only the first one.",
		},
		{
			Type = "Fixed",
			Text = "Egg and decoy clones keep their Humanoid, so they keep their clothes.",
		},
	},
}
