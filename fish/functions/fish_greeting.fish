function fish_greeting
    printf '\033[s'
    chafa --format sixel --size 18x9 ~/.config/fastfetch/logo/darkdevil.png 2>/dev/null
    printf '\033[u'
    set_color -o FFF
    printf '\033[u\033[20C%s\n' " _____                   _      _____                   _   _ "
    printf '\033[u\033[1B\033[20C%s\n' "|  __ \\                 | |    |  __ \\                 (_) | |"
    printf '\033[u\033[2B\033[20C%s\n' "| |  | |   __ _   _ __  | | __ | |  | |   ___  __   __  _  | |"
    printf '\033[u\033[3B\033[20C%s\n' "| |  | |  / _` | | '__| | |/ / | |  | |  / _ \\ \\ \\ / / | | | |"
    printf '\033[u\033[4B\033[20C%s\n' "| |__| | | (_| | | |    |   <  | |__| | |  __/  \\ V /  | | | |"
    printf '\033[u\033[5B\033[20C%s\n' "|_____/   \\__,_| |_|    |_|\\_\\ |_____/   \\___|   \\_/   |_| |_|"
    printf '\033[u\033[9B'
    set_color normal
    fastfetch --key-padding-left 5
end
