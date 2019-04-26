#!/usr/bin/env perl
$extension = '.orig';
$index = 0;
$host = 'https://beagleboard.github.io/newsletter/';
$prefix = 'static/images/newsletter-2019-04_';
LINE: while (<>) {
    if ($ARGV ne $oldargv) {
        if ($extension !~ /\*/) {
            $backup = $ARGV . $extension;
        }
        else {
            ($backup = $extension) =~ s/\*/$ARGV/g;
        }
        rename($ARGV, $backup);
        open(ARGVOUT, ">$ARGV");
        select(ARGVOUT);
        $oldargv = $ARGV;
    }
    if (m/^\s*image:\s*(\S+)\s*$/) {
        $linkext = $oldlink = $1;
        if ($linkext =~ m/\/[\w\.\,]*\.(\w+)([^\w\/\.]|$)/) {
            $linkext = $1;
            print STDOUT ("Image found: $oldlink\n");
            $imagename = sprintf("$prefix%04d.$linkext", $index);
            $index++;
            if (!system("curl '$oldlink' > $imagename")) {
                $i = index($_, $oldlink);
                if ($i > 0) {
                    $newlink = "$host$imagename";
                    substr($_, $i, length($oldlink)) = $newlink;
                    print STDOUT ("New link: $newlink\n");
                } else {
                    print STDERR ("Link substitution failed\n");
                }
                #system("scp $imagename beagleboard.org:beagleboard.org/static/images/");
            } else {
                print STDERR ("Curl failed\n");
            }
        }
    }
}
continue {
    print; # this prints to original filename
}
select(STDOUT);
