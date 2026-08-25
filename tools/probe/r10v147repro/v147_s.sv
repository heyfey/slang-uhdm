// r10uvm147 VERIFIER grid S — the CONSTANT-FOLD risk the widening creates.
// A struct-typed PARAMETER / LOCALPARAM base is a NamedValue the pristine gate
// refused and the patch now admits.  If the whole chain is CONSTANT, golden may
// fold it and we may now build a hier_path where a constant belongs.
package q147vs;
  typedef struct { logic [63:0] arr[4]; logic [63:0] pk; } ss147_t;
  localparam ss147_t PS = '{arr:'{64'h1122334455667788, 64'h2, 64'h3, 64'h4},
                            pk:64'h99AABBCCDDEEFF00};
  localparam logic [7:0] C1 = PS.arr[0][15:8];      // s01 constant context, const range
  localparam logic [7:0] C2 = PS.arr[0][8 +: 8];    // s02 constant context, +:
  localparam logic [7:0] C3 = PS.pk[15:8];          // s03 no index step (control)
  localparam logic [7:0] C4 = PS.arr[1][7:0];       // s04 literal index 1
endpackage

module msub147s #(parameter logic [7:0] W = 8'h0) ();
  logic [7:0] t;
  initial t = W;
endmodule

module m147s;
  import q147vs::*;
  localparam ss147_t LS = '{arr:'{64'hAABBCCDDEEFF0011, 64'h2, 64'h3, 64'h4},
                            pk:64'h1234567890ABCDEF};
  localparam logic [7:0] D1 = LS.arr[0][15:8];      // s05 module-scope const context
  msub147s #(.W(LS.arr[0][15:8])) u1 ();           // s06 PARAMETER OVERRIDE argument
  msub147s #(.W(PS.arr[0][15:8])) u2 ();           // s07 override from a pkg localparam

  int i, j;
  logic [7:0] o;
  logic [63:0] mvar[4];

  initial begin
    o = LS.arr[0][15:8];                            // s08 procedural, FULLY CONSTANT
    o = LS.arr[i][15:8];                            // s09 procedural, variable index
    o = LS.arr[0][8*i +: 8];                        // s10 procedural, variable base
    o = PS.arr[0][15:8];                            // s11 pkg localparam, fully constant
    o = mvar[0][15:8];                              // s12 module VARIABLE control
    o = mvar[i][15:8];                              // s13 module VARIABLE control
  end

  genvar g;
  logic [7:0] og[4];
  for (g = 0; g < 4; g++) begin : gl147
    assign og[g] = LS.arr[g][15:8];                 // s14 GENVAR index, parameter base
  end
endmodule
