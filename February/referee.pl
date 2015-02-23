#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use feature qw(say);
use Carp;
use IPC::Open2;
use Smart::Comments;

my $picker_account = 0;
my $guesser_account = 0;
my $picker_win = 0;
my $guesser_win = 0;
my $guesser1st = 0;
my $guesser2st = 0;
my $guesser3st = 0;
my $guesser4st = 0;
my $guesser5st = 0;

sub score {
    my ($attempt) = @_;

    if ($attempt == 1) {
        $guesser_account += 100;
        $guesser1st++;
    } elsif ($attempt == 2) {
        $guesser_account += 80;
        $picker_account += 20;
        $guesser2st++;
    } elsif ($attempt == 3) {
        $guesser_account += 60;
        $picker_account += 40;
        $guesser3st++;
    } elsif ($attempt == 4) {
        $guesser_account += 40;
        $picker_account += 60;
        $guesser4st++;
    } elsif ($attempt == 5) {
        $guesser_account += 20;
        $picker_account += 80;
        $guesser5st++;
    } elsif ($attempt == 6) {
        $guesser_account += 0;
        $picker_account += 100;
    } else {
        croak "Wrong number of attempts: $attempt";
    }
}

sub execution {
    my ($scriptName) = @_;
    my $found = 0;

    my $pid_picker = open2(my $pick_out, my $pick_in, $scriptName, 'pick');
    my $pid_guesser = open2(my $guess_out, my $guess_in, $scriptName, 'guess');

    my $goal = <$pick_out>;
    chomp($goal);

    for my $guess ( 1 .. 5 ) {
        my $try = <$guess_out>;

        if ($try == $goal) {
            print $guess_in "=\n";
            $found = 1;
            score($guess);
            $guesser_win++;
            last;
        } elsif ($try > $goal) {
            print $guess_in "-\n";
        } else {
            print $guess_in "+\n";
        }
    }

    if(!$found) {
        $picker_win++;
        score(6);
        close ($guess_in);
    }

    waitpid( $pid_guesser, 0 );
    waitpid( $pid_picker, 0 );
}

sub main {
    if (@ARGV != 1) {
        croak "One (and only one) argument should be provided\n";
    }

    my $scriptName = $ARGV[0];
    croak "Script $scriptName doesn't exist" unless -e $scriptName;

    foreach my $execution (1 .. 10000) {  ### Ongoing matches...[%]       done
        execution($scriptName);
    }

    say "FINAL RESULT:";
    say "Picker: $picker_account";
    say "Guesser: $guesser_account";
    say "Picker win: $picker_win";
    say "Guesser win: $guesser_win";
    say "Guesser 1st: $guesser1st";
    say "Guesser 2st: $guesser2st";
    say "Guesser 3st: $guesser3st";
    say "Guesser 4st: $guesser4st";
    say "Guesser 5st: $guesser5st";
}

main();
