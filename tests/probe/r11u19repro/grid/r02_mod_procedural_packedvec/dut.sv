module top(input logic [31:0] a, output logic [1:0] we);
  always_comb we = '{default: '0};
endmodule
