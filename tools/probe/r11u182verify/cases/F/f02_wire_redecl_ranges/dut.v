// § splitPortTsKeyOnPortDecl171
module dut (a, b, o, p);
  input [3:0] a;
  input [3:0] b;
  output [4:0] o;
  output [4:0] p;
  wire [3:0] a, b;
  wire [4:0] o, p;
  assign o = a + b;
  assign p = a - b;
endmodule
