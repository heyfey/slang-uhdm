// § classArrElemVar414
class P #(int W = 2);
  bit [W-1:0] x;
endclass
module top;
  P #(4) arr[2];
  P parr[3];
endmodule
