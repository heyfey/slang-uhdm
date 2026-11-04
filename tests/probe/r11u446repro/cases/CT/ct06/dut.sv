// § clsLocalTdTopHomeInst446
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
  endclass
  typedef pool #(string) str_pool;
endpackage
package q;
  import p::*;
  class C;
    int k;
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
