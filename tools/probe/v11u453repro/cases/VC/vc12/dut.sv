// § vsTrailRangeColonJoin453
package p;
  function automatic void f(int i0);
    logic [3:0][7:0] m [2];
    m[0][i0][i0+:2] = 1;
  endfunction
endpackage
module top;
  import p::f;
  initial f(0);
endmodule
