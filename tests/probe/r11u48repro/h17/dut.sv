// h17 — a $unit-scope localparam bound (the `unitBoundParam` arm one branch
// above the one this pass gates), unsigned.
localparam int unsigned UP = 4;
module h17 (input logic c, output logic o);
  logic [UP:0] x;
  assign o = c ^ x[0];
endmodule
