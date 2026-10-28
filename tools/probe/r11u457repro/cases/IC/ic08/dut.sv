// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v);
    return v;
  endfunction
  function int wrap(int x);
    return rep(x);
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
