module top(input logic [31:0] a, output logic [7:0] we);
  assign we = '{default: 2};
endmodule
