module top(input logic [31:0] a, output logic [1:0] o);
  logic [1:0] v = '{default: '0};
  assign o = v;
endmodule
