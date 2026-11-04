// § naArrNetOwnPortDecl155v
module dut(o, i);
  output [1:0] o [2];
  input [1:0] i;
  wire [1:0] o [2];
  assign o[0] = i; assign o[1] = ~i;
endmodule
