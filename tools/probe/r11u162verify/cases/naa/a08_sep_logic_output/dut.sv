// § naArrNetOwnPortDecl155v
module dut(o, i);
  output o;
  input [1:0] i;
  logic [1:0] o [2];
  assign o[0] = i; assign o[1] = ~i;
endmodule
