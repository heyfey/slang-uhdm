// § cloneLhsIdxPartSelBind450
package p;
  task t(int i0);
    logic [15:0] d;
    logic [3:0][7:0] m;
    d[i0+:8] <= 1;
    d[i0+:4] += 2;
    m[i0][2] <= 1;
    m[i0][i0] |= 1;
  endtask
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
