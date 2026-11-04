// § tfArgScalarTdWriter223 — a virtual method overridden in a derived class of an importing package, a static method and a constructor, all with scalar typedef formals
package p;
  typedef int     FILE_T;
  typedef bit [2:0] SEL_T;
  class base_c;
    function new(FILE_T f = 0); endfunction
    virtual function void v(SEL_T s, FILE_T f); endfunction
    static function int st(SEL_T s); return s; endfunction
  endclass
endpackage
package q;
  import p::*;
  class der_c extends base_c;
    function new(FILE_T f = 1); super.new(f); endfunction
    virtual function void v(SEL_T s, FILE_T f); endfunction
  endclass
endpackage
module top;
  import q::*;
endmodule
