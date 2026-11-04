// § classArrElemVar414
module top();
  class C; int x; endclass
  C arr[3];
  initial arr[0] = new;
endmodule
