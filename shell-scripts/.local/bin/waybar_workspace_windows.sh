#!/usr/bin/env bash

set -euo pipefail

active_ws="$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // empty')"
active_addr="$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')"

if [[ -z "${active_ws}" ]]; then
  printf '{"text":"","tooltip":""}\n'
  exit 0
fi

hyprctl clients -j 2>/dev/null | jq -c \
  --argjson ws "$active_ws" \
  --arg active "$active_addr" '
  def clean:
    tostring
    | gsub("[\\n\\r\\t]+"; " ")
    | gsub("  +"; " ")
    | if length > 42 then .[0:39] + "…" else . end;

  def esc: @html;

  def display_title:
    . as $window
    | ($window.title // $window.class // "window")
    | if (($window.class // "") | ascii_downcase | contains("zen")) then
        sub(" — Zen Browser$"; "")
      else
        .
      end;

  [.[] | select(.workspace.id == $ws and .floating == false)]
  | sort_by(.at[0], .at[1])
  | if length <= 1 then
      { text: "", tooltip: "" }
    else
      {
        text: (
          map(
            (display_title | clean | esc) as $title
            | if .address == $active then
                "<span color=\"#dfb46a\">" + $title + "</span>"
              else
                $title
              end
          )
          | join(" <span color=\"#6A95DF\">-</span> ")
        ),
        tooltip: (
          map(
            (if .address == $active then "● " else "  " end)
            + (display_title | clean)
          )
          | join("\n")
        )
      }
    end
  '
