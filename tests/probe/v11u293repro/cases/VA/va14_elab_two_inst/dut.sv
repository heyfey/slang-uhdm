// § defNetClassArrTsDimEnd293
// A module holding a class array instantiated twice.
class C; int x; endclass
module m;
  C a [];
  int r_o;
  initial r_o = a.size();
endmodule
module top;
  m u1 ();
  m u2 ();
endmodule
