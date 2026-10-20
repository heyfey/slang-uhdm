// § classArrElemVar414
module top();
  class P #(int W = 4); logic [W-1:0] v; endclass
  P #(8) arr[2];
  P plain[2];
endmodule
