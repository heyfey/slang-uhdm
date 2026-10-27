// § cloneBodyCallBindsHomeTopTf446
package p;
  function automatic int rep(int v);
    return v + 1;
  endfunction
  function automatic int wrap(int v);
    return rep(v) + rep(v + 1);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  import q::*;
  int o;
  initial o = wrap(1);
endmodule
