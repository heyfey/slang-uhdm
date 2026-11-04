// § importCloneBodyLocalCopies175
package p1;
  task automatic t(int n);
    int x = n;
    begin : blk
      int y = x + 1;
      for (int i = 0; i < 2; i++) begin
        int z = i;
        x += z;
      end
    end
    fork
      begin int w = 3; x += w; end
    join
  endtask
endpackage
package p2;
  import p1::*;
endpackage
module top; initial p1::t(1); endmodule
