// h10 — `integer`: the same question, integer_typespec.
module h10 (input logic c, output logic o);
  localparam integer P = 4;
  logic [P:0] x;
  assign o = c ^ x[0];
endmodule
