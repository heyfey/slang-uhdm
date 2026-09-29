// § strLitPpEscIdShift224
package p;
  class c;
    function string f(); string s; s = "a\nb` c"; return s; endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c;
    function string g(); return f(); endfunction
  endclass
endpackage
module top; endmodule
