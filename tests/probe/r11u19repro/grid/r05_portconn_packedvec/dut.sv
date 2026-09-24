module ch(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
module top(input logic [31:0] a, output logic [1:0] o);
  ch u(.i('{default: '0}), .o(o));
endmodule
