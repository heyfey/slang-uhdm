// § cloneRetNoMintBindsHome232
package p1;
  class c;
    extern function logic [7:0] f(int a);
  endclass
  function logic [7:0] c::f(int a);
    f = a;
    f[0] = 1'b1;
    if (f[1]) f = f + 1;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  import p3::*;
  assign o = 1;
endmodule
