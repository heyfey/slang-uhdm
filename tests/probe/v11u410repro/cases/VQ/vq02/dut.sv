// § classBoundedQueueMultiDim410
class C;
  logic [3:0] q[$:3][2];
  string s[$:2][2];
  int t[2][3][$];
endclass
module top; C c = new; endmodule
