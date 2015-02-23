#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use feature qw(say);
use Carp;
$| = 1; # Autoflush (well... no buffering actually)

my $random;
eval {
    require Math::Random::Secure;
    Math::Random::Secure->import("irand");
    $random = sub {
        return irand(shift);
    }
} or do {
    $random = sub {
        return int(rand(shift));
    }
};

sub playPick_random {
    # int(rand(100)) is random between 0 and 99
    my $chosen_number = $random->(100) + 1;
    say $chosen_number;
}

sub playPick_static {
    my @good_numbers = (
        1, 2, 7, 8, 9,
        11, 12, 13, 17, 18, 19,
        21, 22, 23, 28, 29,
        31, 32, 37, 38, 39,
        41, 43, 42, 47, 48, 49,
        51, 52, 53, 58, 59,
        61, 62, 67, 68, 69,
        71, 72, 73, 78, 79,
        81, 82, 83, 88, 89,
        91, 92, 97, 98, 99, 100);
    my $chosen_number = $good_numbers[$random->(scalar @good_numbers)];
    croak "Wrong choice\n" unless $chosen_number;
    say $chosen_number;
}

sub playGuess_almost_binary {
    my @range = (1, 100);
    my $random_maxminus = sub {
        my @neg = (1, -1);
        return $random->((shift) + 1) * $neg[$random->(2)];
    };


    my $chosen_number = 50 + $random_maxminus->(5);
    say $chosen_number;
    while (1) {
        my $input = <STDIN>;
        exit(-1) unless $input;
        if (chomp($input) =~ /[+-=]/) {
            if ($range[1] == $range[0]) {
                return if $input eq '=';
                say $range[0];
                next;
            }
            if ($input eq '+') {
                $range[0] = $chosen_number + 1;

                # Range init + Half range +/- 20% range
                $chosen_number = $range[0] + int(($range[1] - $range[0]) / 2) +
                    $random_maxminus->(int(($range[1] - $range[0]) * 0.2));

                say $chosen_number;
            } elsif ($input eq '-') {
                $range[1] = $chosen_number - 1;

                # Range init + Half range +/- 20% range
                $chosen_number = $range[0] + int(($range[1] - $range[0]) / 2) +
                    $random_maxminus->(int(($range[1] - $range[0]) * 0.2));

                say $chosen_number;
            } else {
                return;
            }
        } else {
            croak "Incorrect answer input: \"$input\"\n";
        }
    }
}

sub playGuess_random {
    my $chosen_number = $random->(100) + 1;
    my @range = (1, 100);
    say $chosen_number;

    while (1) {
        my $input = <STDIN>;
        exit(-1) unless $input;
        if (chomp($input) =~ /[+-=]/) {
            if ($range[1] == $range[0]) {
                return if $input eq '=';
                say $range[0];
                next;
            }
            if ($input eq '+') {
                $range[0] = $chosen_number + 1;
                $chosen_number = $random->($range[1] - $range[0])  + $range[0];

                say $chosen_number;
            } elsif ($input eq '-') {
                $range[1] = $chosen_number - 1;
                $chosen_number = $random->($range[1] - $range[0])  + $range[0];

                say $chosen_number;
            } else {
                return;
            }
        } else {
            croak "Incorrect answer input: $input\n";
        }
    }
}

sub playGuess {
    my $random_guess = sub {
        my @strategies = (\&playGuess_almost_binary, \&playGuess_random);
        return $strategies[$random->(2)];
    };

    ($random_guess->())->();
}

sub playPick {
    my $random_pick = sub {
        my @strategies = (\&playPick_static, \&playPick_random);
        return $strategies[$random->(2)];
    };

    ($random_pick->())->();
}

sub main {
    if (@ARGV != 1) {
        croak "One (and only one) argument should be provided\n";
    }

    if ($ARGV[0] eq "pick") {
        playPick();
    } elsif ($ARGV[0] eq "guess") {
        playGuess();
    } else {
        croak "Argument $ARGV[0] unknown. Please choose \"pick\" or \"guess\"\n";
    }
}

main();
