package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test::More 0.88;

sub mytest (@);	## no critic (ProhibitSubroutinePrototypes)

`pbcopy -help 2>&1`;
if ($?) {
    plan skip_all => 'Pbcopy program not found.';
    exit;
}

Mac::Pasteboard->set (fatal => 0);
my $pb = Mac::Pasteboard->new ();
if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr) {
    plan skip_all => 'No access to desktop (maybe running as cron job?)';
    exit;
}
$pb or die Mac::Pasteboard->get ('status');

{
    open (my $fh, '|-', 'pbcopy')
	or die "Unable to open pipe to pbcopy: $!\n";
    print $fh <<eod;
The Bustard's a genial fowl,
With minimal reason to growl.
    He escapes what would be
    Illegitimacy
By means of a fortunate vowel.
eod
    close $fh;
}

mytest kPasteboardModified, 'Modify the pasteboard after we attached to it';

$pb->clear ();
mytest kPasteboardClientIsOwner, 'Clear the pasteboard, which makes us owner';

done_testing;

sub mytest (@) {	## no critic (ProhibitSubroutinePrototypes, RequireArgUnpacking)
    my $got = $pb->synch ();
    my $expect = shift;
    @_ = ( $expect == $got, "@_" );
    goto &ok;
}

1;
