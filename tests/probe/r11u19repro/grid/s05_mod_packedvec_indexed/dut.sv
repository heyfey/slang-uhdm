module top(input logic [31:0] a, output logic [3:0] we);
  assign we = '{default: '0, 0: 1'b1};
endmodule
