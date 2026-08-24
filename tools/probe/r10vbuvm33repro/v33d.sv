// r10vbuvm33 v33d.sv — the OTHER POSITIONS of a `::`-scoped DATA reference
// (all of which reach Surelog through compileExpression, not compileVariable)
// beside buvm32's scoped CALLS, with a REGISTERED-qualifier twin for each.
// The patch must leave every one of them byte-identical.  MEASUREMENT ONLY.
package pd33;
  class dsrc33;
    static int    sq33 [$];
    static int    sa33 [4];
    static int    sc33;
    static logic [7:0] sv33;
    static function int sf33(int a); return a; endfunction
    static function void sp33(); endfunction
  endclass
  int pvar33 [4];
  int pscal33;
  function automatic int pfn33(int a); return a; endfunction
endpackage

module top33d (output int po33);
  import pd33::*;
  int r33, arr33 [4];
  logic [7:0] w33;
  wire [31:0] cw33;
  assign cw33 = dsrc33::sc33;                          // D1  cont_assign Rhs
  sub33 u33 (.p33(dsrc33::sc33));                      // D2  port actual
  initial begin
    r33 = dsrc33::sc33;                                // D3  bare read Rhs
    dsrc33::sc33 = r33;                                // D4  Lhs
    r33 = dsrc33::sa33[1];                             // D5  indexed read
    dsrc33::sa33[1] = r33;                             // D6  indexed Lhs
    r33 = dsrc33::sv33[3:1];                           // D7  part select
    r33 = dsrc33::sv33[r33 +: 2];                      // D8  indexed part select
    r33 = $size(dsrc33::sa33);                         // D9  $size argument
    r33 = $bits(dsrc33::sv33);                         // D10 $bits argument
    r33 = pd33::pscal33;                               // D11 package qualifier
    r33 = pd33::pvar33[2];                             // D12 package indexed
    r33 = pd33::dsrc33::sc33;                          // D13 three segments
    $display("%0d %0d", dsrc33::sc33, pd33::pscal33);  // D14 call arguments
    r33 = dsrc33::sf33(dsrc33::sc33);                  // D15 scoped CALL + arg
    dsrc33::sp33();                                    // D16 scoped void call
    r33 = pd33::pfn33(pd33::pscal33);                  // D17 package free fn
    r33 = {dsrc33::sc33, pd33::pscal33};               // D18 concat members
    if (dsrc33::sc33 > 0) r33 = 1;                     // D19 condition
    r33 = fn33(dsrc33::sc33);                          // D20 return path arg
    foreach (dsrc33::sq33[i]) r33 = i;                 // D21 THE LAW's own cell
    foreach (arr33[i])       r33 = i;                  // D22 bare control
  end
  function automatic int fn33(int a);
    return dsrc33::sc33 + a;                           // D23 return expression
  endfunction
  assign po33 = pd33::pscal33;                         // D24 output cont_assign
endmodule

module sub33 (input int p33);
endmodule
