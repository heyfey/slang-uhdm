// § defNetClassArrTsDimEnd293
// A fixed dimension followed by a dynamic one.
class C; int x; endclass
module top;
  C a [2][];
  int r_o;
  initial r_o = a[0].size();
endmodule
