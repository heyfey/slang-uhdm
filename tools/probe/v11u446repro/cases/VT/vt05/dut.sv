// § clsLocalTdTopHomeInst446
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
    T v;
  endclass
  typedef pool #(string) str_pool;
endpackage
package q;
  import p::*;
  typedef str_pool sp2_t;
  class D;
    sp2_t z;
  endclass
endpackage
module top;
  import p::*;
  import q::*;
  typedef pool #(string) local_t;
  D d;
  local_t l;
endmodule
