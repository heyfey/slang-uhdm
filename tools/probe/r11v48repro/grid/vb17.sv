// vb17 — the we24 2x2 on an INTERFACE, signed int.
interface vb17i #(parameter int P = 4) (input logic c);
  logic [P:0] x;
endinterface
module vb17 (input logic c, output logic o);
  vb17i #(.P(8)) i1 (.c(c));
  vb17i          i2 (.c(c));
  assign o = c ^ i1.x[0] ^ i2.x[0];
endmodule
