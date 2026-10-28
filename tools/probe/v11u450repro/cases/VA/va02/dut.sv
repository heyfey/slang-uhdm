// § clsAssocVecIdxTs450
class C #(int W = 4);
  int a[bit[7:0]];
  logic [W-1:0] b[logic[3:0]];
endclass
module top;
  C #(8) c8 = new;
  C c4 = new;
endmodule
