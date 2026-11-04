// § cloneLhsIdxPartSelBind450
package p;
  function automatic void f(int i0);
    logic [15:0] d;
    begin
      logic [15:0] d;
      d[i0+:4] = 3;
    end
    d[i0+:2] = 1;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
