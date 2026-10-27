// § clsLocalTdTopHomeInst446
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
  endclass
  typedef pool #(pool #(int)) pp_t;
endpackage
package q;
  import p::*;
  class D;
    pp_t z;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
