// § strLitPpEscIdShift224
package p;
  function automatic string f(); string s; s = "a\nb` c"; return s; endfunction
endpackage
module top(output string o);
  import p::*;
  assign o = f();
endmodule
