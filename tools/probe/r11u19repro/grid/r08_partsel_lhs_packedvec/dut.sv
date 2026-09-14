module top(input logic [31:0] a, output logic [3:0] we);
  assign we[1:0] = '{default: '0};
endmodule
