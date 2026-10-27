// § clsLocalTdTopHomeInst446
package r;
  class pool #(type T = int);
    typedef pool #(T) this_type;
    static function this_type get();
      return null;
    endfunction
  endclass
endpackage
package p;
  import r::*;
  typedef r::pool #(string) str_pool;
endpackage
package q;
  import p::*;
  class C;
    str_pool x;
    function void f(); x = str_pool::get(); endfunction
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
