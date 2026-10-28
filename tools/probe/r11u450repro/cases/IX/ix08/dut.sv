// § cloneLhsIdxPartSelBind450
package p;
  function automatic void f(output logic [15:0] d, input int i0);
    d[i0*8+:8] = 1;
    d[i0-:2] = 0;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
