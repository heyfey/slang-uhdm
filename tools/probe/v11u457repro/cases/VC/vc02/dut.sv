// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v); return 2 + v; endfunction
  function int wrap(int v); return rep(v); endfunction
endpackage
package q;
  import p::*;
  function int own(int b); return b; endfunction
endpackage
module top;
  import q::*;
  initial $display(own(1));
endmodule
