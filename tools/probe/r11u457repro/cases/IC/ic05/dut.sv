// § importCloneRetCallCopiesShare457
package p;
  function int rep(int v);
    return v + 1;
  endfunction
  function int wrap(int x);
    return rep(x);
  endfunction
endpackage
package q;
  import p::*;
  function int qf(int b);
    return b;
  endfunction
endpackage
package r;
  import q::*;
  function int rf(int b);
    return b;
  endfunction
endpackage
module top;
  import r::*;
  initial $display(rf(1));
endmodule
