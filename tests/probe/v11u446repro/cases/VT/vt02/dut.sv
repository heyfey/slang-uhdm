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
package q1;
  import p::*;
  class C1;
    str_pool x;
  endclass
endpackage
package q2;
  import p::*;
  class C2;
    str_pool y;
    function void f(); y = str_pool::get(); endfunction
  endclass
endpackage
module top;
  import q1::*;
  import q2::*;
  C1 a;
  C2 b;
endmodule
