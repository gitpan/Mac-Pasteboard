package main;

use strict;
use warnings;

use Mac::Pasteboard qw{:all};
use Test::More 0.88;

{
    Mac::Pasteboard->set (fatal => 0);
    Mac::Pasteboard->new ();
    if (Mac::Pasteboard->get ('status') == coreFoundationUnknownErr ()) {
	plan skip_all => 'No access to desktop (maybe running as cron job?)';
	exit;
    }
    Mac::Pasteboard->set (fatal => 1);
}

{
    my $text = 'Deck us all with Boston Charlie';
    my $orig = Mac::Pasteboard->new (kPasteboardUniqueName);

    ok $orig, 'Instantiate unique-named pasteboard';
    $orig->clear ();
    $orig->copy ($text);

    my $rslt = $orig->paste ();
    is $rslt, $text, 'Data round-trip';

    my $clone = $orig->clone ();
    ok $clone, 'Clone pasteboard object';

    ok $clone ne $orig, 'Clone should be different object';

    $rslt = $clone->paste ();
    is $rslt, $text, 'Original text should be accessible through clone';

    $orig = undef;	# Garbage collect.
    $rslt = $clone->paste ();
    is $rslt, $text, 'Should still be accessible after original blown away';
}

done_testing;

1;

# ex: set textwidth=72 :
