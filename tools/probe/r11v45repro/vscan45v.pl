#!/usr/bin/perl
# r11v45/vscan — INDEPENDENT a-priori mover prediction.
# Finds every `[local]param type A = B` whose default B is a BARE IDENTIFIER,
# and reports whether B names a type parameter declared EARLIER in the same
# parameter list (a BORROW candidate) or something else (a typedef etc).
# Also flags a SHADOW: B is an earlier type parameter AND a typedef of the same
# name exists in the same file (the v3 face, where golden does NOT borrow).
use strict; use warnings;
my @roots = @ARGV;
my @files;
for my $r (@roots) {
  open(my $f, "-|", "find", $r, "-type", "f", "(", "-name", "*.sv", "-o", "-name", "*.v",
       "-o", "-name", "*.svh", "-o", "-name", "*.vh", ")") or die;
  while (<$f>) { chomp; push @files, $_; }
}
printf("scanned %d files\n", scalar @files);
my $hits = 0;
for my $p (@files) {
  open(my $fh, "<", $p) or next;
  local $/; my $src = <$fh>; close $fh;
  next unless defined $src;
  my $nocmt = $src;
  $nocmt =~ s{/\*.*?\*/}{}gs;
  $nocmt =~ s{//[^\n]*}{}g;
  my %typedefs; $typedefs{$1} = 1 while $nocmt =~ /\btypedef\b[^;]*?\b(\w+)\s*;/gs;
  # walk parameter lists: each `#(` ... matching `)` is approximated by the
  # ordered sequence of `type NAME = DEFAULT` declarators in the file, reset at
  # every `module`/`interface`/`class`/`package` keyword.
  my @decls;
  my $order = 0;
  while ($nocmt =~ /\b(module|interface|class|package|endmodule|endinterface|endclass|endpackage)\b|(?:\b(?:parameter|localparam)\s+)?\btype\s+(\w+)\s*=\s*([^,;\)]+)/gs) {
    if (defined $1) { @decls = (); next; }
    my ($nm, $def) = ($2, $3);
    $def =~ s/\s+$//; $def =~ s/^\s+//;
    my $isbare = ($def =~ /^\w+$/) ? 1 : 0;
    if ($isbare) {
      my $earlier = grep { $_ eq $def } @decls;
      if ($earlier) {
        my $shadow = $typedefs{$def} ? "SHADOW" : "-";
        printf("BORROW %-70s %-16s = %-16s %s\n", $p, $nm, $def, $shadow);
        $hits++;
      }
    }
    push @decls, $nm;
  }
}
printf("borrow candidate sites: %d\n", $hits);
