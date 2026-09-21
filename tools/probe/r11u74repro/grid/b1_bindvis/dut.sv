// r11u74 b1 — LAW B JUDGE VISIBILITY, ISOLATED.  No struct parameter, no
// fold: the ONLY thing that can differ on row `ns` is the Lhs ref's
// vpiActual.  Row `uq` is the POSITIVE CONTROL: same shape, no module-body
// namesake, so both sides must be unbound and the cell must agree.
module dut (input logic a_i, output logic [31:0] o);
  logic [31:0] ns;                 // module-body namesake
  for (genvar i = 0; i < 1; i = i + 1) begin : gl
    logic [31:0] ns;               // gen-local namesake hit
    logic [31:0] uq;               // no namesake anywhere
    assign ns = 32'd7;             // constant Rhs
    assign uq = 32'd7;             // constant Rhs, control
  end
  assign o  = gl[0].ns ^ gl[0].uq ^ ns;
  assign ns = {31'd0, a_i};
endmodule
