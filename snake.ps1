# CmdSnake - Terminal Snake

# GitHub -> PowerShell -> CMD

# No Python required

$ErrorActionPreference = "Stop"

$Width = 50
$Height = 20
$BaseDelay = 120
$MinDelay = 55

$highScore = 0

function New-Food {
do {
$x = Get-Random -Minimum 0 -Maximum $Width
$y = Get-Random -Minimum 0 -Maximum $Height

```
    $used = $false

    foreach ($part in $script:snake) {
        if ($part.X -eq $x -and $part.Y -eq $y) {
            $used = $true
            break
        }
    }
} while ($used)

[PSCustomObject]@{
    X = $x
    Y = $y
}
```

}

function Draw {

```
[Console]::SetCursorPosition(0, 0)

$esc = [char]27

$green = "$esc[92m"
$darkGreen = "$esc[32m"
$red = "$esc[91m"
$cyan = "$esc[96m"
$yellow = "$esc[93m"
$white = "$esc[97m"
$gray = "$esc[90m"
$bold = "$esc[1m"
$reset = "$esc[0m"

$text = New-Object System.Text.StringBuilder

[void]$text.Append(
    "${bold}${cyan}╔" + ("═" * $Width) + "╗${reset}`n"
)

$title = " S N A K E "
$left = [int](($Width - $title.Length) / 2)
$right = $Width - $left - $title.Length

[void]$text.Append(
    "${cyan}║${reset}" +
    (" " * $left) +
    "${bold}${white}${title}${reset}" +
    (" " * $right) +
    "${cyan}║${reset}`n"
)

[void]$text.Append(
    "${bold}${cyan}╠" + ("═" * $Width) + "╣${reset}`n"
)

for ($y = 0; $y -lt $Height; $y++) {

    $row = ""

    for ($x = 0; $x -lt $Width; $x++) {

        $char = " "

        if ($script:food.X -eq $x -and $script:food.Y -eq $y) {
            $char = "${bold}${red}●${reset}"
        }

        for ($i = 0; $i -lt $script:snake.Count; $i++) {

            if (
                $script:snake[$i].X -eq $x -and
                $script:snake[$i].Y -eq $y
            ) {

                if ($i -eq 0) {
                    $char = "${bold}${green}█${reset}"
                }
                elseif ($i % 3 -eq 0) {
                    $char = "${darkGreen}░${reset}"
                }
                elseif ($i % 3 -eq 1) {
                    $char = "${darkGreen}▓${reset}"
                }
                else {
                    $char = "${darkGreen}█${reset}"
                }

                break
            }
        }

        $row += $char
    }

    [void]$text.Append(
        "${cyan}║${reset}${row}${cyan}║${reset}`n"
    )
}

[void]$text.Append(
    "${bold}${cyan}╠" + ("═" * $Width) + "╣${reset}`n"
)

$scoreText = " SCORE: $script:score    BEST: $script:highScore "
$scoreLeft = [int](($Width - $scoreText.Length) / 2)
$scoreRight = $Width - $scoreLeft - $scoreText.Length

[void]$text.Append(
    "${cyan}║${reset}" +
    (" " * $scoreLeft) +
    "${bold}${yellow}${scoreText}${reset}" +
    (" " * $scoreRight) +
    "${cyan}║${reset}`n"
)

$controls = "WASD / ARROWS = MOVE    Q = QUIT"
$controlLeft = [int](($Width - $controls.Length) / 2)
$controlRight = $Width - $controlLeft - $controls.Length

[void]$text.Append(
    "${cyan}║${reset}" +
    (" " * $controlLeft) +
    "${gray}${controls}${reset}" +
    (" " * $controlRight) +
    "${cyan}║${reset}`n"
)

[void]$text.Append(
    "${bold}${cyan}╚" + ("═" * $Width) + "╝${reset}"
)

[Console]::Write($text.ToString())
```

}

function Play-Game {

```
$script:snake = @(
    [PSCustomObject]@{ X = 25; Y = 10 }
    [PSCustomObject]@{ X = 24; Y = 10 }
    [PSCustomObject]@{ X = 23; Y = 10 }
)

$script:direction = "RIGHT"
$script:nextDirection = "RIGHT"
$script:score = 0
$script:delay = $BaseDelay

$script:food = New-Food

Clear-Host

[Console]::CursorVisible = $false

try {

    while ($true) {

        while ([Console]::KeyAvailable) {

            $key = [Console]::ReadKey($true)

            switch ($key.Key) {

                "UpArrow" {
                    if ($script:direction -ne "DOWN") {
                        $script:nextDirection = "UP"
                    }
                }

                "DownArrow" {
                    if ($script:direction -ne "UP") {
                        $script:nextDirection = "DOWN"
                    }
                }

                "LeftArrow" {
                    if ($script:direction -ne "RIGHT") {
                        $script:nextDirection = "LEFT"
                    }
                }

                "RightArrow" {
                    if ($script:direction -ne "LEFT") {
                        $script:nextDirection = "RIGHT"
                    }
                }

                "W" {
                    if ($script:direction -ne "DOWN") {
                        $script:nextDirection = "UP"
                    }
                }

                "S" {
                    if ($script:direction -ne "UP") {
                        $script:nextDirection = "DOWN"
                    }
                }

                "A" {
                    if ($script:direction -ne "RIGHT") {
                        $script:nextDirection = "LEFT"
                    }
                }

                "D" {
                    if ($script:direction -ne "LEFT") {
                        $script:nextDirection = "RIGHT"
                    }
                }

                "Q" {
                    return "QUIT"
                }
            }
        }

        $script:direction = $script:nextDirection

        $headX = $script:snake[0].X
        $headY = $script:snake[0].Y

        switch ($script:direction) {
            "UP" {
                $headY--
            }

            "DOWN" {
                $headY++
            }

            "LEFT" {
                $headX--
            }

            "RIGHT" {
                $headX++
            }
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

        foreach ($part in $script:snake) {

            if (
                $part.X -eq $headX -and
                $part.Y -eq $headY
            ) {
                $hitSelf = $true
                break
            }
        }

        if ($hitSelf) {
            break
        }

        # New head

        $newHead = [PSCustomObject]@{
            X = $headX
            Y = $headY
        }

        $script:snake = @(
            $newHead
        ) + @(
            $script:snake
        )

        # Food

        if (
            $headX -eq $script:food.X -and
            $headY -eq $script:food.Y
        ) {

            $script:score++

            if ($script:score -gt $script:highScore) {
                $script:highScore = $script:score
            }

            $script:delay = [math]::Max(
                $MinDelay,
                $BaseDelay - ($script:score * 2)
            )

            $script:food = New-Food
        }
        else {

            if ($script:snake.Count -gt 1) {

                $script:snake = @(
                    $script:snake[0..($script:snake.Count - 2)]
                )
            }
        }

        Draw

        Start-Sleep -Milliseconds $script:delay
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
Write-Host ("║              FINAL SCORE: {0,-18}║" -f $script:score) -ForegroundColor Yellow
Write-Host ("║              BEST SCORE:  {0,-18}║" -f $script:highScore) -ForegroundColor Cyan
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
```

}

try {

```
while ($true) {

    $result = Play-Game

    if ($result -eq "RESTART") {
        continue
    }

    break
}
```

}
finally {

```
[Console]::CursorVisible = $true
Write-Host ""

}
