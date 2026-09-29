// § cloneHpIdxNamesByChain220
package p1;
  class d; int m; function int g(); return m; endfunction endclass
  class c;
    d arr[4];
    extern function int f(int i);
  endclass
  function int c::f(int i);
    return arr[i].g();
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
