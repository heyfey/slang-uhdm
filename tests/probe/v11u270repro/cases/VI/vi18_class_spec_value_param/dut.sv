// § insideSetParamFoldKeepsPa270
package p;
  class c #(int P = 1, int Q = 2);
    function bit f(int w); return w inside {P, Q}; endfunction
  endclass
  class d;
    c #(5) x;
    c y;
  endclass
endpackage
module top;
  import p::*;
  d z;
endmodule
