// § cloneRetNoMintBindsHome232
// a plain return-name write and selects on it in one body; an inc/dec on the return name
package p1;
  class c;
    extern function logic [7:0] f(int a);
  endclass
  function logic [7:0] c::f(int a);
    f = a[7:0];
    f[0] = 1'b0;
    f[3:2] = f[1:0];
    f++;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
