// § ifaceUdpShapedNoRefMod476
interface a_if(input [1:0] c, input rst);
  logic [31:0] A;
endinterface
module top;
  logic a, b, rst;
  a_if u({a, b}, rst);
endmodule
