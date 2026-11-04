// § defNetClassArrTsDimEnd293
// A fixed-size class handle array in a module.
class C; int x; endclass
module top;
  C a [4];
  int r_o;
  initial begin a[0] = new(); r_o = a[0].x; end
endmodule
