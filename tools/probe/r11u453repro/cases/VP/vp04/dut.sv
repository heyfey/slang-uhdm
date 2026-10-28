// § vsTrailRangeParenStart453
package p;
  function automatic logic [1:0] f(int i0);
    logic [3:0][7:0] m;
    return m[i0][(i0+1)-:2];
  endfunction
endpackage
module top;
  import p::*;
endmodule
