// § cloneTfItemLocalOwnVar253 (a class-handle local, method call and member read)
package p;
  class node;
    int v;
    function int get(); return v; endfunction
  endclass
  function automatic int f;
    node n;
    int r;
    n = new;
    r = n.get() + n.v;
    return r;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
