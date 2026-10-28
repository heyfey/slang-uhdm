// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v); return v + 1; endfunction
  function int wrap(int v); return rep(v); endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = wrap(3);
endmodule
