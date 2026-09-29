// § cloneHpIdxNamesByChain220
package p1;
  class d; int m; endclass
  class c;
    d arr[4];
    extern function void f(int i);
  endclass
  function void c::f(int i);
    arr[i].m = 2;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
