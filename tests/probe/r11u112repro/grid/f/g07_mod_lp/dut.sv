module top (input logic [7:0] a, output logic y);
  localparam int unsigned L = 2;
  assign y = a[L+1];
endmodule
