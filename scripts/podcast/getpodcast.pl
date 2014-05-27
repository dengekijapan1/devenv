#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use Getopt::Std;

my $script_dir = $FindBin::Bin;
my $pod_dir = "~/podcast";
my @src_dirs = (
    "$pod_dir/News/NHK\\ World\\ Radio\\ Japan\\ English",
    "$pod_dir/News/NHK\\ World\\ Radio\\ Japan\\ Espanol",
);

my $res;
my @files;
my @lines;

my $month = {
    January => '01',
    February => '02',
    March => '03',
    April => '04',
    May => '05',
    June => '06',
    July => '07',
    August => '08',
    September => '09',
    October => '10',
    November => '11',
    December => '12',
};

my $day = {
    1 => '01',
    2 => '02',
    3 => '03',
    4 => '04',
    5 => '05',
    6 => '06',
    7 => '07',
    8 => '08',
    9 => '09',
    10 => '10',
    11 => '11',
    12 => '12',
    13 => '13',
    14 => '14',
    15 => '15',
    16 => '16',
    17 => '17',
    18 => '18',
    19 => '19',
    20 => '20',
    21 => '21',
    22 => '22',
    23 => '23',
    24 => '24',
    25 => '25',
    26 => '26',
    27 => '27',
    28 => '28',
    29 => '29',
    30 => '30',
    31 => '31',
};

`/usr/bin/podget -s -l $pod_dir`;
`/usr/bin/podget -s -l $pod_dir -C --cleanup_days 10`;

foreach my $src_dir (@src_dirs) {
    $res = `ls -lat --time-style=long-iso $src_dir`;
    @files = split /\n/, $res;

    foreach my $file (@files) {
        if ($file =~ /^\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(.+\.mp3)$/) {
            my $file = $1;
            $res = `id3v2 -l $src_dir/$file`;
            @lines = split /\n/, $res;
            foreach (@lines) {
                if (/^TIT2\s+.+: NHK WORLD RADIO JAPAN - (\w+ News) at (.+), (\w+) (\d+)$/) {
                    `id3v2 --TIT2 \"$1 $month->{$3}-$day->{$4} $2\" $src_dir/$file`;
                }
            }
        }
    }
}
