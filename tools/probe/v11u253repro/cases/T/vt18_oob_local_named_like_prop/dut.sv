// § cloneTfItemLocalOwnVar253 (an out-of-block paren-less method whose local shares a property's name)
package p;
  class c;
    int v;
    extern function int f();
  endclass
  function int c::f;
    int v;
    v = this.v + 1;
    return v;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
