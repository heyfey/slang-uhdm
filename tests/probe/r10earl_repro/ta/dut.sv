// r10earl7 witness ta — DEF-VIEW GEN-BLOCK unpacked-array declaration.
// ranked residue (5): `logic [5:0] x [32];` inside `if (P) begin : g ... end`
// gets an array_typespec in golden's module DEF listing; we emit none.
// Row E of nn.sv proved the PLAIN module-scope shape already agrees, so the
// witness keeps a module-scope control beside the gen-scope subject.
module ta #(
  parameter bit RVB = 1'b0,
  parameter int NN  = 4
) (
  input  logic       clk_i,
  input  logic [5:0] a_i,
  output logic [5:0] z_o
);

  // CONTROL — plain module scope (already agrees per nn.sv row E)
  logic [ 5:0] ctl_partial [32];
  logic [31:0] ctl_packed;

  assign ctl_packed = 32'h0;

  if (RVB) begin : g_rvb
    // SUBJECT — the ibex_alu shape, in a NOT-TAKEN generate branch
    logic        gs_scalar;
    logic [31:0] gs_packed;
    logic [ 5:0] gs_partial [32];          // literal-bound unpacked dim
    logic [ 5:0] gs_ranged  [0:7];         // ranged unpacked dim
    logic [ 5:0] gs_param   [NN];          // parameter-bound unpacked dim
    logic        gs_2d      [4][2];        // two unpacked dims

    assign gs_scalar = 1'b0;
    assign gs_packed = {26'b0, gs_partial[31]};
  end : g_rvb

  if (!RVB) begin : g_norvb
    // SUBJECT — the TAKEN branch, same shape
    logic [ 5:0] gt_partial [32];
    assign z_o = gt_partial[0];
  end : g_norvb

  assign z_o = a_i;

endmodule
