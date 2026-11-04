// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  function int wrap(int b);
    int v;
    v = b;
    return rep(b);
  endfunction
endpackage
package q;
  import p::*;
  function int own(int b);
    return b;
  endfunction
endpackage
module top;
  import q::*;
  initial $display(own(1));
endmodule
