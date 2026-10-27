// § clsTdFirstSameClass442v
class C;
endclass
package q;
  class C;
    int b;
  endclass
endpackage
module aa;
  typedef C d_t;
  d_t g;
endmodule
module top;
  typedef q::C c_t;
  c_t h;
  aa u();
endmodule
