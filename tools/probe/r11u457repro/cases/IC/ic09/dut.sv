// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  function int wrap(int x);
    return rep(x);
  endfunction
endpackage
module top;
  import p::*;
  initial $display(wrap(1));
endmodule
