// v99 b6 - parenthesised compound bounds (does a paren make a compound bound
// behave like a primary in golden?), constant-folded contexts, and a
// tolerance range (SV-2023) for crash-safety.
package pk99b6;
  localparam int PV6 = 4;
  localparam int QV6 = 20;
endpackage
module mub6;
  import pk99b6::*;
  int t61, t62, t63, t64, t65, t66;
  int c61, c62, c63, c64, c65, c66;
  logic sel6;
  // constant-folded contexts
  always @(*) begin
    // parenthesised binary first bound
    if (t61 inside {[(PV6+1):QV6]})          c61 = 1;
    // unparenthesised binary first bound (known R1)
    if (t62 inside {[PV6+1:QV6]})            c62 = 2;
    // parenthesised unary first bound
    if (t63 inside {[(-PV6):QV6]})           c63 = 3;
    // parenthesised ternary first bound
    if (t64 inside {[(sel6 ? 1 : 2):QV6]})   c64 = 4;
    // doubly parenthesised binary first bound
    if (t65 inside {[((PV6+1)):QV6]})        c65 = 5;
    // parenthesised binary SECOND bound, primary first
    if (t66 inside {[PV6:(QV6-1)]})          c66 = 6;
  end
endmodule
