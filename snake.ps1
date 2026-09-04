$ErrorActionPreference = "SilentlyContinue"

$Width = 50
$Height = 20
$BaseDelay = 120
$MinDelay = 55

function Start-SnakeGame {

$snake = @(
    [PSCustomObject]@{ X = 25; Y = 10 }
    [PSCustomObject]@{ X = 24; Y = 10 }
    [PSCustomObject]@{ X = 23; Y = 10 }
)

$direction = "RIGHT"
$nextDirection = "RIGHT"
$score = 0
$delay = $BaseDelay

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

    [Console]::SetCursorPosition(0, 0)

    $green = [char]27 + "[92m"
    $darkGreen = [char]27 + "[32m"
    $red = [char]27 + "[91m"
    $cyan = [char]27 + "[96m"
    $yellow = [char]27 + "[93m"
    $white = [char]27 + "[97m"
    $gray = [char]27 + "[90m"
    $bold = [char]27 + "[1m"
    $reset = [char]27 + "[0m"

    $output = New-Object System.Text.StringBuilder

    [void]$output.Append(
        "${bold}${cyan}╔" + ("═" * $Width) + "╗${reset}`n"
    )

    $title = " S N A K E "
    $left = [int](($Width - $title.Length) / 2)

    [void]$output.Append(
        "${bold}${cyan}║${reset}" +
        (" " * $left) +
        "${bold}${white}${title}${reset}" +
        (" " * ($Width - $left - $title.Length)) +
        "${bold}${cyan}║${reset}`n"
    )

    [void]$output.Append(
        "${bold}${cyan}╠" + ("═" * $Width) + "╣${reset}`n"
    )

    for ($y = 0; $y -lt $Height; $y++) {

        $row = ""

        for ($x = 0; $x -lt $Width; $x++) {

            $character = " "

            if ($food.X -eq $x -and $food.Y -eq $y) {
                $character = "${bold}${red}●${reset}"
            }

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

        [void]$output.Append(
            "${cyan}║${reset}${row}${cyan}║${reset}`n"
        )
    }

    [void]$output.Append(
        "${bold}${cyan}╠" + ("═" * $Width) + "╣${reset}`n"
    )

    $stats = " SCORE: $score "
    $statsLeft = [int](($Width - $stats.Length) / 2)

    [void]$output.Append(
        "${cyan}║${reset}" +
        (" " * $statsLeft) +
        "${bold}${yellow}${stats}${reset}" +
        (" " * ($Width - $statsLeft - $stats.Length)) +
        "${cyan}║${reset}`n"
    )

    $controls = "WASD / ARROWS = MOVE    Q = QUIT"
    $controlsLeft = [int](($Width - $controls.Length) / 2)

    [void]$output.Append(
        "${cyan}║${reset}" +
        (" " * $controlsLeft) +
        "${gray}${controls}${reset}" +
        (" " * ($Width - $controlsLeft - $controls.Length)) +
        "${cyan}║${reset}`n"
    )

    [void]$output.Append(
        "${bold}${cyan}╚" + ("═" * $Width) + "╝${reset}"
    )

    [Console]::Write($output.ToString())
}

$food = Spawn-Food

Clear-Host
[Console]::CursorVisible = $false

try {

    while ($true) {

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
                    return "QUIT"
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

        $newHead = [PSCustomObject]@{
            X = $headX
            Y = $headY
        }

        $snake = @($newHead) + @($snake)

        if ($headX -eq $food.X -and $headY -eq $food.Y) {

            $score++

            $delay = [math]::Max(
                $MinDelay,
                $BaseDelay - ($score * 2)
            )

            $food = Spawn-Food
        }
        else {

            if ($snake.Count -gt 1) {
                $snake = @(
                    $snake[0..($snake.Count - 2)]
                )
            }
        }

        Draw-Game

        Start-Sleep -Milliseconds $delay
    }

}
finally {
    [Console]::CursorVisible = $true
}

Clear-Host

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║                                                  ║" -ForegroundColor Red
Write-Host "║                    GAME OVER                     ║" -ForegroundColor Red
Write-Host "║                                                  ║" -ForegroundColor Red
Write-Host ("║              FINAL SCORE: {0,-18}║" -f $score) -ForegroundColor Yellow
Write-Host "║                                                  ║" -ForegroundColor Red
Write-Host "║             R = RESTART   Q = QUIT              ║" -ForegroundColor Gray
Write-Host "║                                                  ║" -ForegroundColor Red
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

while ($true) {

    $key = [Console]::ReadKey($true)

    if ($key.Key -eq "R") {
        return "RESTART"
    }

    if ($key.Key -eq "Q") {
        return "QUIT"
    }
}

}

try {

while ($true) {

    $result = Start-SnakeGame

    if ($result -eq "QUIT") {
        break
    }

    if ($result -eq "RESTART") {
        Clear-Host
        continue
    }

    break
}

}
finally {

[Console]::CursorVisible = $true
Write-Host ""

}
