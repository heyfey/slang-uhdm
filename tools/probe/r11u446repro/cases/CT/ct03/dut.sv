// § clsLocalTdTopHomeInst446
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
    static function this_type get();
      return null;
    endfunction
  endclass
  typedef pool #(string) str_pool;
endpackage
module top;
  import p::*;
  str_pool x;
endmodule
