#!/bin/bash
# linkkey.sh <links-sorted-file>: reduce each line to: callname @loc | first enclosing function/task + its container | target
perl -ne 'chomp; my ($c,$t)=split /\t-> /; my @p=split /</,$c; my $call=$p[0]; my $sub=""; my $cont=""; for my $i (1..$#p){ if($p[$i]=~/^(function|task):/){ $sub=$p[$i]; $cont=$p[$i+1]//""; last; } } $sub=~s/@[0-9:]+//; $cont=~s/@[0-9:]+//; print "$call | $sub < $cont | $t\n";' $1 | sort
