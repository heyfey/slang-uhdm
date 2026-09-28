// § unitBoundFoldAtLeftOperand200
module top #(parameter W = 4, parameter [W*2-1:0] H = 3) ();
  localparam [W*2*2-1:0] L = 2;
  logic [31:0] y;
  assign y = H + L;
endmodule
