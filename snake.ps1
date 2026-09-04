powershell
# CmdSnake - Terminal Snake
# Runs directly in PowerShell / CMD
# No Python required

$ErrorActionPreference = "SilentlyContinue"

$Width = 50
$Height = 20
$Delay = 120
$MinDelay = 55

$snake = @(
    [PSCustomObject]@{ X = 25; Y = 10 }
    [PSCustomObject]@{ X = 24; Y = 10 }
    [PSCustomObject]@{ X = 23; Y = 10 }
)

$direction = "RIGHT"
$nextDirection = "RIGHT"
$score = 0
$highScore = 0

function Hide-Cursor {
    [Console]::CursorVisible = $false
}

function Show-Cursor {
    [Console]::CursorVisible = $true
}

function Move-CursorHome {
    [Console]::SetCursorPosition(0, 0)
}

function Spawn-Food {
    do {
        $foodX = Get-Random -Minimum 1 -Maximum ($Width - 1)
        $foodY = Get-Random -Minimum 0 -Maximum $Height

        $occupied = $false

        foreach ($part in $snake) {
            if ($part.X -eq $foodX -and $part.Y -eq $foodY) {
                $occupied = $true
                break
            }
        }
    } while ($occupied)

    return [PSCustomObject]@{
        X = $foodX
        Y = $foodY
    }
}

function Draw-Game {
    Move-CursorHome

    $green = "`e[92m"
    $darkGreen = "`e[32m"
    $red = "`e[91m"
    $cyan = "`e[96m"
    $yellow = "`e[93m"
    $white = "`e[97m"
    $gray = "`e[90m"
    $bold = "`e[1m"
    $reset = "`e[0m"

    $lines = New-Object System.Collections.Generic.List[string]

    $lines.Add("${bold}${cyan}╔" + ("═" * $Width) + "╗${reset}")

    $title = " S N A K E "
    $lines.Add(
        "${bold}${cyan}║${reset}" +
        "${bold}${white}" +
        $title.PadLeft([math]::Floor(($Width + $title.Length) / 2)).PadRight($Width) +
        "${reset}${bold}${cyan}║${reset}"
    )

    $lines.Add("${bold}${cyan}╠" + ("═" * $Width) + "╣${reset}")

    for ($y = 0; $y -lt $Height; $y++) {

        $row = ""

        for ($x = 0; $x -lt $Width; $x++) {

            $character = " "

            # Food
            if ($food.X -eq $x -and $food.Y -eq $y) {
                $character = "${bold}${red}●${reset}"
            }

            # Snake
            for ($i = 0; $i -lt $snake.Count; $i++) {

                if ($snake[$i].X -eq $x -and $snake[$i].Y -eq $y) {

                    if ($i -eq 0) {
                        $character = "${bold}${green}█${reset}"
                    }
                    elseif ($i % 3 -eq 0) {
                        $character = "${darkGreen}░${reset}"
                    }
                    elseif ($i % 3 -eq 1) {
                        $character = "${darkGreen}▓${reset}"
                    }
                    else {
                        $character = "${darkGreen}█${reset}"
                    }

                    break
                }
            }

            $row += $character
        }

        $lines.Add("${cyan}║${reset}${row}${cyan}║${reset}")
    }

    $lines.Add("${bold}${cyan}╠" + ("═" * $Width) + "╣${reset}")

    $stats = " SCORE: $score    BEST: $highScore "
    $stats = $stats.PadLeft([math]::Floor(($Width + $stats.Length) / 2)).PadRight($Width)

    $lines.Add(
        "${cyan}║${reset}${bold}${yellow}${stats}${reset}${cyan}║${reset}"
    )

    $controls = "WASD / ARROWS = MOVE    Q = QUIT"
    $controls = $controls.PadLeft([math]::Floor(($Width + $controls.Length) / 2)).PadRight($Width)

    $lines.Add(
        "${cyan}║${reset}${gray}${controls}${reset}${cyan}║${reset}"
    )

    $lines.Add("${bold}${cyan}╚" + ("═" * $Width) + "╝${reset}")

    [Console]::Write(($lines -join "`n"))
}

function Game-Over {

    Clear-Host

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                                                  ║" -ForegroundColor Red
    Write-Host "║                    GAME OVER                     ║" -ForegroundColor Red
    Write-Host "║                                                  ║" -ForegroundColor Red
    Write-Host ("║              FINAL SCORE: {0,-18}║" -f $score) -ForegroundColor Yellow
    Write-Host ("║              BEST SCORE:  {0,-18}║" -f $highScore) -ForegroundColor Cyan
    Write-Host "║                                                  ║" -ForegroundColor Red
    Write-Host "║             R = RESTART   Q = QUIT              ║" -ForegroundColor Gray
    Write-Host "║                                                  ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Red
}

try {

    [Console]::CursorVisible = $false
    Clear-Host

    $food = Spawn-Food

    while ($true) {

        # Read every key waiting in the terminal
        while ([Console]::KeyAvailable) {

            $key = [Console]::ReadKey($true)

            switch ($key.Key) {

                "UpArrow" {
                    if ($direction -ne "DOWN") {
                        $nextDirection = "UP"
                    }
                }

                "DownArrow" {
                    if ($direction -ne "UP") {
                        $nextDirection = "DOWN"
                    }
                }

                "LeftArrow" {
                    if ($direction -ne "RIGHT") {
                        $nextDirection = "LEFT"
                    }
                }

                "RightArrow" {
                    if ($direction -ne "LEFT") {
                        $nextDirection = "RIGHT"
                    }
                }

                "W" {
                    if ($direction -ne "DOWN") {
                        $nextDirection = "UP"
                    }
                }

                "S" {
                    if ($direction -ne "UP") {
                        $nextDirection = "DOWN"
                    }
                }

                "A" {
                    if ($direction -ne "RIGHT") {
                        $nextDirection = "LEFT"
                    }
                }

                "D" {
                    if ($direction -ne "LEFT") {
                        $nextDirection = "RIGHT"
                    }
                }

                "Q" {
                    return
                }
            }
        }

        $direction = $nextDirection

        $headX = $snake[0].X
        $headY = $snake[0].Y

        switch ($direction) {
            "UP"    { $headY-- }
            "DOWN"  { $headY++ }
            "LEFT"  { $headX-- }
            "RIGHT" { $headX++ }
        }

        # Wall collision
        if (
            $headX -lt 0 -or
            $headX -ge $Width -or
            $headY -lt 0 -or
            $headY -ge $Height
        ) {
            break
        }

        # Self collision
        $hitSelf = $false

        foreach ($part in $snake) {
            if ($part.X -eq $headX -and $part.Y -eq $headY) {
                $hitSelf = $true
                break
            }
        }

        if ($hitSelf) {
            break
        }

        # Add new head
        $newHead = [PSCustomObject]@{
            X = $headX
            Y = $headY
        }

        $snake = @($newHead) + @($snake)

        # Food
        if ($headX -eq $food.X -and $headY -eq $food.Y) {

            $score++

            if ($score -gt $highScore) {
                $highScore = $score
            }

            $Delay = [math]::Max(
                $MinDelay,
                120 - ($score * 2)
            )

            $food = Spawn-Food
        }
        else {
            if ($snake.Count -gt 1) {
                $snake = @($snake[0..($snake.Count - 2)])
            }
        }

        Draw-Game

        Start-Sleep -Milliseconds $Delay
    }

    Game-Over

    while ($true) {

        $key = [Console]::ReadKey($true)

        if ($key.Key -eq "R") {
            & $MyInvocation.MyCommand.Path
            break
        }

        if ($key.Key -eq "Q") {
            break
        }
    }

}
finally {
    Show-Cursor
    Write-Host ""
}
```
