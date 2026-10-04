// § cloneRetNoMintBindsHome232
package p1;
  class c;
    extern function int f(int a);
  endclass
  function int c::f(int a);
    f = a + 1;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
