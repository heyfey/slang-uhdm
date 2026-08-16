// r10uvm78 arm c3 — vpiConstantSelect ACROSS THE WHOLE LEGAL BOUND LATTICE.
//
// The old gates read the BOUNDS: the SIMPLE arm demanded both ends evaluable,
// the INDEXED arm demanded an evaluable width (§ hierSelConstWidthSuffices17).
// Surelog reads NOTHING — compilePartSelectRange stamps the flag on every
// part_select and every indexed_part_select it builds
// (Surelog/src/DesignCompile/CompileExpression.cpp:4256 and :4281, the only two
// MakePart_select / MakeIndexed_part_select sites in the whole of Surelog).
//
// The lattice is walked only where IEEE 1800 lets it be walked, and the
// boundary is itself the finding:
//
//   s1  v[3:0]      both ends literal            old gate TRUE   -> unchanged
//   s2  v[W-1:0]    both ends param-foldable     old gate TRUE   -> unchanged
//   s5  v[n +: 4]   variable base, const width   old gate TRUE   -> unchanged
//   s6  v[3 +: W]   const base, param width      old gate TRUE   -> unchanged
//   q3  q[n:0]      QUEUE, variable LEFT end     old gate FALSE  -> MOVES
//   q4  q[3:n]      QUEUE, variable RIGHT end    old gate FALSE  -> MOVES
//
// There is no s7.  A variable WIDTH in an indexed part-select is ILLEGAL in
// IEEE 1800 (`constant_expression` in the grammar) and slang rejects it, which
// is why § hierSelConstWidthSuffices17's gate could never read false on a legal
// design and why the whole corpus population of R2 is SIMPLE part_selects on
// QUEUES — the one shape whose range is allowed to be non-constant at all.
//
// Everything golden emits here must read vpiConstantSelect:1.  If ANY cell of
// this arm comes back without it, the law is false and the pass must stop.
module top78c3 #(parameter int W = 4) ();
  logic [63:0] v;
  logic [63:0] o;
  int q[$];
  int r[$];
  int n;
  initial begin
    n = 5;
    o[3:0]   = v[3:0];      // s1
    o[7:4]   = v[W-1:0];    // s2
    o[31:24] = v[n +: 4];   // s5
    o[39:32] = v[3 +: W];   // s6
    r = q[n:0];             // q3
    r = q[3:n];             // q4
  end
endmodule
