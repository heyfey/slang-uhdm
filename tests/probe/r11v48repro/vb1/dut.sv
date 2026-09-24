// vb1 — signed `int` localparam bound. REGRESSION FACE: golden TS, must stay.
module vb1 (input logic c, output logic o);
  localparam int P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
