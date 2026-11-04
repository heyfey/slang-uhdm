// § clsTdFirstSameClass442v
package p;
  class C;
    int a;
  endclass
  typedef C pc_t;
endpackage
package q;
  class C;
    int b;
  endclass
  typedef C qc_t;
endpackage
module top;
  typedef q::C c_t;
  c_t h;
endmodule
