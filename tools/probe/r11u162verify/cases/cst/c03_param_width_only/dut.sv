// § elabCastSharesDeclRef154
module dut #(parameter int unsigned W = 3) (input logic x, output logic [2:0] o);
  assign o = x ? W'(1) : W'(6);
endmodule
module top(input logic x, output logic [2:0] o); dut #(.W(3)) u(x, o); endmodule
