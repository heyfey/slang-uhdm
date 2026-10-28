// § cloneLhsIdxPartSelBind450
package p;
  task automatic t(int i0);
    logic [15:0] d;
    d[i0*8+:8] = 1;
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
