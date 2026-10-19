// § classBoundedQueueMultiDim410
class C #(parameter N = 3);
  int q[$:N][2];
  int r[2][];
  shortint u[2][$:N];
  rand int v[$:2][2];
endclass
module top; C c = new; endmodule
