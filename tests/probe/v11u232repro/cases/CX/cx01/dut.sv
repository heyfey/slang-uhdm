// § cloneRetNoMintBindsHome232
// return-name selects: a part select, a bit select with a call index, an indexed part select
package p1;
  class c;
    extern function logic [7:0] f(int a);
    function int g(); return 2; endfunction
  endclass
  function logic [7:0] c::f(int a);
    f[3:0] = a[3:0];
    f[g()] = 1'b1;
    f[4 +: 2] = 2'b10;
    f[7] = f[0];
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
