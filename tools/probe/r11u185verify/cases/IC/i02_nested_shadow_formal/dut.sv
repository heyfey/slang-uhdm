// § importCloneBodyLocalCopies175
package p1;
  function automatic int f(int n);
    int acc = 0;
    begin : blk
      int n = 5;
      acc = acc + n;
    end
    if (acc > 0) begin
      int t [2] = '{1, 2};
      acc += t[1];
    end
    return acc + n;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top; int r; initial r = p1::f(3); endmodule
