// r10vbuvm34repro/v34f.sv — VERIFIER ARM F: `::` SPELLINGS the predicate may
// not recognise — `$unit::`, a THREE-segment class path, a parameterised class
// specialisation `C#(..)::`, and a typedef alias of the class used as the
// qualifier.  Each has a bare twin.  MEASUREMENT ONLY.
class uq34;
  typedef uq34 this_type;
  static int uarr34 [$];
  static int ua34 [string];
endclass

package pf34;
  class inner34;
    typedef inner34 this_type;
    static int iq34 [$];
    static int ia34 [string];
  endclass
  class outer34 #(int W = 4);
    typedef outer34#(W) this_type;
    static int oq34 [$];
    static string os34 [$];
  endclass
  typedef inner34 alias34;
endpackage

module mf34;
  import pf34::*;
  int r34;
  initial begin
    foreach ($unit::uq34::uarr34[i]) r34 = i;    // F1 $unit:: three segments
    foreach ($unit::uq34::ua34[i])   r34 = 1;    // F2
    foreach (uq34::uarr34[i])        r34 = i;    // F3 two segments, $unit class
    foreach (pf34::inner34::iq34[i]) r34 = i;    // F4 pkg::class::member
    foreach (pf34::inner34::ia34[i]) r34 = 1;    // F5
    foreach (inner34::iq34[i])       r34 = i;    // F6 class::member
    foreach (alias34::iq34[i])       r34 = i;    // F7 typedef alias qualifier
    foreach (alias34::ia34[i])       r34 = 1;    // F8
    foreach (outer34#(8)::oq34[i])   r34 = i;    // F9 specialisation qualifier
    foreach (outer34#(8)::os34[i])   r34 = i;    // F10
  end
endmodule
