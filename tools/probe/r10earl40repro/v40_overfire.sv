// r10earl40 VERIFIER over-fire probe: shapes the new ScopedName gate could
// mis-claim.  Every net is c_<cell> so cells40.py can read it.
package q40;
  parameter int W = 8;
  parameter logic [3:0][7:0] A = {8'h1, 8'h2, 8'h3, 8'h4};
  parameter logic [3:0][7:0] B = {8'h5, 8'h6, 8'h7, 8'h8};
  parameter logic [1:0][3:0][7:0] C = {32'h01020304, 32'h05060708};
endpackage

interface sif40;
  logic [3:0][7:0] arr;
  modport mp (input arr);
endinterface

module leaf40 (input logic [7:0] i, output logic [7:0] o);
  assign o = i;
endmodule

module v40_overfire #(parameter int DW = 8) (input logic [7:0] in0, output logic [7:0] out0);
  logic [3:0][7:0] loc;
  assign loc = q40::A;

  for (genvar g = 0; g < 2; g++) begin : gb
    // 1. WHITESPACE between the qualified base and its first selector.
    logic [7:0] c_ws;
    assign c_ws = q40::A [g] [DW-1:0];

    // 2. A NESTED qualified multi-select INSIDE the index of another one.
    logic [7:0] c_nest;
    assign c_nest = q40::A[q40::B[g][1:0]][DW-1:0];

    // 3. A DOTTED hierarchical base with a multi-select tail.
    logic [7:0] c_dot;
    assign c_dot = u_if.arr[g][DW-1:0];

    // 4. Qualified base, THREE selectors.
    logic [7:0]  c_three;
    assign c_three = q40::C[g][1][DW-1:0];

    // 5. Qualified base, multi-select, inside a FUNCTION-CALL argument.
    logic [7:0] c_arg;
    leaf40 u_leaf (.i(q40::A[g][DW-1:0]), .o(c_arg));

    // 6. Bare local base with a dotted-qualified index (control).
    logic [7:0] c_locidx;
    assign c_locidx = loc[g][DW-1:0];
  end

  sif40 u_if();
  assign out0 = in0;
endmodule
