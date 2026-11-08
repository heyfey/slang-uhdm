// § enumCastChainKeepsInnerCast493
package p;
  int pv;
endpackage
module top(output int v);
  typedef int t32;
  function int f();
    return int'(t32'(p::pv));
  endfunction
  assign v = f();
endmodule
