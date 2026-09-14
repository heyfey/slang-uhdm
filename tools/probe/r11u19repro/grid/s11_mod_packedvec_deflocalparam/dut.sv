module top(input logic [31:0] a, output logic [7:0] we);
  localparam int Q = 1;
  assign we = '{default: Q};
endmodule
