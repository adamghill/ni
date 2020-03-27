import terminal


proc exit*(): int =
    # reset terminal on exit
    system.addQuitProc(resetAttributes)

proc print*(text: string, fgColor: ForegroundColor=fgDefault, indention: string=""): int =
    if fgColor != fgDefault:
        setForegroundColor(fgColor)

    echo indention, text

    if fgColor != fgDefault:
        setForegroundColor(fgWhite)

proc newLine*(): int =
    echo ""
