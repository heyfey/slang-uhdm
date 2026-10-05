// § cloneTfItemLocalOwnVar253 (a paren-less method inside the class body)
package p;
  class c;
    int m;
    function int f;
      int x;
      x = m;
      return x;
    endfunction
  endclass
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
