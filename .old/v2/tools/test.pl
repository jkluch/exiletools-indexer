#!/usr/bin/perl

# This is just a simple dev/test script to verify the formJSON subroutine is doing what you want on an item
# just give it an md5sum and go.

use Search::Elasticsearch;
use DBI;
use JSON;
use JSON::XS;
use Encode;
use Data::Dumper;
use Time::HiRes;
use Parallel::ForkManager;
use utf8;
use Text::Unidecode;
require("subs/all.subroutines.pl");
require("subs/sub.formatJSON.pl");

# == Initial Options 
# Whether or not to give basic debug output
$debug = 1;

# Whether or not to give SUPER VERBOSE output. USE WITH CARE! Will create huge logs
# and tons of spammy text.
$sv = 1;

$dbh = DBI->connect("dbi:mysql:$conf{dbName}","$conf{dbUser}","$conf{dbPass}") || die "DBI Connection Error: $DBI::errstr\n";

if ($ARGV[0] eq "random") {
  # This is so ghetto
  my @array = @{$dbh->selectcol_arrayref("select `md5sum` from `raw-json`")};
  $md5sum = $array[rand @array];
} else {
  $md5sum = $ARGV[0];
}


my $rawjson = $dbh->selectrow_array("select `data` from `raw-json` where `md5sum`=\"$md5sum\"");

local %item;
$item{DEBUG}{"This isn't valid JSON for import!"} = 1;
my $jsonout = &formatJSON("$rawjson");
if ($jsonout =~ /^FAIL/) {
  print "ERROR: Item parsing failed with $jsonout\n";
  exit;
}

my $json = JSON->new;
print "== [$md5sum] Original JSON = ==============================\n";
print $json->pretty->encode($json->decode($rawjson))."\n";
print "== [$md5sum] Formatted JSON  ==============================\n";
print $json->pretty->encode($json->decode($jsonout))."\n";
