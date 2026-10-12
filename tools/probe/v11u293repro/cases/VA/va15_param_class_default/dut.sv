// § defNetClassArrTsDimEnd293
// An unspecialized parameterized class array.
class C #(int W = 2); logic [W-1:0] x; endclass
module top;
  C a [];
  int r_o;
  initial r_o = a.size();
endmodule
