// § naArrNetOwnPortDecl155v
module dut(i, o);
  input [1:0] i [2];
  output [1:0] o;
  wire [1:0] i [2];
  assign o = i[0] ^ i[1];
endmodule
