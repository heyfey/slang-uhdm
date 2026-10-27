// § clsLocalTdTopHomeInst446
package p;
  class pool #(type T = int);
    typedef pool #(T) this_type;
    static function this_type get();
      return null;
    endfunction
  endclass
  typedef pool #(string) str_pool;
  class U;
    str_pool z;
  endclass
endpackage
module top;
  import p::*;
  U u;
  str_pool s;
  initial s = str_pool::get();
endmodule
