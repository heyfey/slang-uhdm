use strict; use warnings;
my @kw = qw(logic bit reg byte int integer shortint longint time real shortreal realtime wire string void chandle event signed unsigned struct union enum type);
my %kw = map {$_=>1} @kw;
my $hits=0;
for my $f (@ARGV) {
  open(my $fh,'<',$f) or next;
  local $/; my $t = <$fh>; close $fh;
  # strip line comments and block comments
  $t =~ s{//[^\n]*}{}g; $t =~ s{/\*.*?\*/}{}gs;
  while ($t =~ /\b(?:parameter|localparam)\s+type\s+\w+\s*=\s*([A-Za-z_]\w*(?:\s*::\s*[A-Za-z_]\w*)*)\s*\[/gs) {
    my $e = $1; my $last = (split(/::/, $e))[-1]; $last =~ s/\s//g;
    my $first = (split(/::/, $e))[0]; $first =~ s/\s//g;
    next if $kw{$first};
    print "$f: $e\[\n"; $hits++;
  }
}
print "-- hits=$hits\n";
