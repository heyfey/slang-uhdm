module top #(parameter int unsigned P = 5) (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[5:0];
  assign o = x;
endmodule
