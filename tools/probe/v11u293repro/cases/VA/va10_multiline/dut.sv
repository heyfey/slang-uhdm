// § defNetClassArrTsDimEnd293
// The dimension on the next line.
class C; int x; endclass
module top;
  C a
    [];
  int r_o;
  initial r_o = a.size();
endmodule
