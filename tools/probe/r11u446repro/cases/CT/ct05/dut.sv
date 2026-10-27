// § clsLocalTdTopHomeInst446
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
    static function this_type get();
      return null;
    endfunction
  endclass
  typedef pool #(string) str_pool;
  typedef pool #(int) int_pool;
endpackage
package q;
  import p::*;
  class C;
    int_pool x;
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
