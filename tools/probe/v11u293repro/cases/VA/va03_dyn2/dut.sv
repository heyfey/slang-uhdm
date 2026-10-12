// § defNetClassArrTsDimEnd293
// A two-dimension dynamic class array.
class C; int x; endclass
module top;
  C a [][];
  int r_o;
  initial begin a = new[2]; r_o = a.size(); end
endmodule
