// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v, int w); return v + w; endfunction
  function int wrap(int v, int w); return rep(v, w); endfunction
endpackage
package q;
  import p::*;
  function int own(int b); return b; endfunction
endpackage
package s;
  import p::*;
  function int own2(int b); return b; endfunction
endpackage
module top;
  import q::*;
  import s::*;
  initial $display(own(1) + own2(2));
endmodule
