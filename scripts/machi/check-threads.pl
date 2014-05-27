#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use Storable;
use DateTime;
use utf8;
use Encode;

my $userAgent = "Mozilla/5.0 (MSIE 9.0; Windows NT 6.1; Trident/5.0)";
my %options;

getopts('', \%options);

my $threadsUrl = "http://sikoku.machi.to/sikoku/subback.html";
# my $threadsUrl = "http://localhost/a.html";
my $res        = `wget -O - -U \"$userAgent\" $threadsUrl`;

my @lines      = split /\n/, $res;

my $prevThreadResCounts;
my $newThreadResCounts;
my $newThreadHrefs;

foreach (@lines) {
    my $line = $_;

    # if ($line =~ /<a href="http:\/\/sikoku\.machi\.to\/bbs\/read\.cgi\/sikoku\/(\d+)\/l50">\d+: (.+)\((\d+)\)<\/a>/) {
    if ($line =~ /<a href="(\d+)\/l50">\d+: (.+)\((\d+)\)<\/a>/) {
        my $threadHref                     = $1;
        my $threadName                     = $2;
        my $threadResCount                 = $3;
        $newThreadHrefs->{$threadName}     = $threadHref;
        $newThreadResCounts->{$threadName} = $threadResCount;
    }
}

$res = `ls -d *-*-*-*-*-*`;
my @hashs = split /\n/, $res;
my $last  = "";
$last     = pop @hashs;

if ($last ne '') {
    $prevThreadResCounts = retrieve("$last/hash");
}

my $eql = "";
my $upd = "";
my $new = "";
my @downloadNames;

foreach (keys(%$newThreadResCounts)) {
    my $key   = $_;
    my $value = $newThreadResCounts->{$key};

    if (exists($prevThreadResCounts->{$key})) {
        my $prevValue = $prevThreadResCounts->{$key};

        if ($value == $prevValue) {
            $eql .= "E $key $value\n";
        } else {
            my $diff = $value - $prevValue;
            $upd .= "U $key $prevValue + $diff\n";
            push @downloadNames, $key;
        }
    } else {
        $new .= "N $key $value\n";
        push @downloadNames, $key;
    }
}

my $now = DateTime->now(time_zone=>'local');
my $dir = $now->strftime('%Y-%m-%d-%H-%M-%S');

`mkdir $dir`;

store $newThreadResCounts, "$dir/hash";

open FH, ">", "$dir/res";
print FH $new;
print FH "\n";
print FH $upd;
print FH "\n";
print FH $eql;
print FH "\n";
close FH;

foreach my $name (@downloadNames) {
    my $thread = $newThreadHrefs->{$name};
    my $url    = "http://sikoku.machi.to/bbs/read.cgi/sikoku/$thread/l50";
    `cd $dir; wget -O $thread -U \"$userAgent\" $url`;
    # print "cd $dir; wget -O $thread -U \"$userAgent\" $url\n";
}
