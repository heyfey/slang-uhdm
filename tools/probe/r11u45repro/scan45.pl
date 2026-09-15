#!/usr/bin/perl
# r11u45/scan45.pl — A PRIORI MOVER PREDICTION for § typeParamChainBorrow45.
#
# The law fires on exactly one written shape: inside ONE parameter list, a
# `[local]param type A = B;` whose default `B` is a BARE IDENTIFIER that names
# a type parameter DECLARED EARLIER IN THAT SAME LIST.  Anything else (a
# typedef name, a package-qualified name, a keyword, a struct/enum, a name with
# a written dimension, a FORWARD reference) does not.
#
# This scans source text, so it over-approximates (it cannot see a same-named
# typedef shadowing) — over-approximation is the safe direction for a mover
# prediction: every predicted file is checked byte-wise afterwards.
use strict; use warnings;
my @files = @ARGV;
for my $f (@files) {
  open(my $fh, '<', $f) or next;
  local $/; my $src = <$fh>; close $fh;
  $src =~ s{//[^\n]*}{}g;            # line comments
  $src =~ s{/\*.*?\*/}{}gs;          # block comments
  # Parameter lists: `#( ... )` headers AND module bodies are both single
  # declaration scopes for this law; Surelog's `*parameters` vector is per
  # compileParameterDeclaration call, i.e. per DECLARATION, but the vector
  # persists across the whole list, so scan each `#(...)` group and, separately,
  # each contiguous run of body parameter declarations.
  while ($src =~ /#\s*\((.*?)\)\s*\(/gs) {
    my $list = $1;
    my @tp;   # type params seen so far, in order
    for my $item (split /,(?![^(\[]*[\)\]])/, $list) {
      if ($item =~ /\b(?:local)?param(?:eter)?\s+type\s+(\w+)\s*=\s*([A-Za-z_]\w*)\s*$/s) {
        my ($name, $def) = ($1, $2);
        print "HIT $f  param type $name = $def   (earlier-in-list: ",
              (grep { $_ eq $def } @tp) ? "YES" : "no", ")\n"
          if grep { $_ eq $def } @tp;
        push @tp, $name;
      } elsif ($item =~ /\b(?:local)?param(?:eter)?\s+type\s+(\w+)/s) {
        push @tp, $1;
      } elsif ($item =~ /^\s*(\w+)\s*=/s && @tp) {
        # continuation declarator without a keyword: not a type param unless the
        # previous one was; conservative — ignore.
      }
    }
  }
}
