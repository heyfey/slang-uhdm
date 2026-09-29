// § strLitContOwnerEnd224
package p;
  class c;
    function string f(bit b); return b ? "x" : "ab \
cd"; endfunction
  endclass
endpackage
package q;
  import p::*;
  class d extends c; endclass
endpackage
module top; endmodule
