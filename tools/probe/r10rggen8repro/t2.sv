// r10rggen8 t2: an UNPACKED-ARRAY localparam declared inside a generate
// for-loop body (elab gen scope) — golden gives it vpiSize, an array_typespec
// ref, a vpiRange, and a param_assign whose Rhs is the assignment pattern.
// Siblings: a scalar localparam in the same scope (already right), the same
// unpacked-array localparam at MODULE level, and one inside an if-generate.
module top (output logic [1:0] o0, output logic [1:0] o1);
  localparam bit [1:0] MOD_INIT[4] = '{2'h0, 2'h1, 2'h2, 2'h3};

  genvar i;
  generate for (i = 0; i < 2; ++i) begin : g
    localparam bit [1:0] INITIAL_VALUE[4] = '{2'h0, 2'h1, 2'h2, 2'h3};
    localparam int SCALAR = 7;
    wire [1:0] w;
    assign w = INITIAL_VALUE[i] + SCALAR[1:0];
  end endgenerate

  generate if (1) begin : gi
    localparam bit [1:0] IF_INIT[2] = '{2'h1, 2'h2};
    wire [1:0] wi;
    assign wi = IF_INIT[0];
  end endgenerate

  assign o0 = g[0].w;
  assign o1 = gi.wi + MOD_INIT[1];
endmodule
