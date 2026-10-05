// § cloneTfItemLocalOwnVar253 (control: a paren-less prototype, a definition with parens)
package p;
  class c;
    int m;
    extern function int f;
  endclass
  function int c::f();
    int x;
    x = m;
    return x;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
