// § strLitContOwnerEnd224
package p;
  function automatic string f(bit c); return c ? "x" : "ab \
cd"; endfunction
endpackage
module top(output string o);
  import p::*;
  assign o = f(1);
endmodule
