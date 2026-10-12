// § cloneRetNameSelRefBindsHomeReturn293
// The select write sits in a nested named block.
package p1;
  function logic [7:0] f();
    f = 8'h0;
    begin : blk
      f[0] = 1'b1;
    end
    f = f << 1;
  endfunction
endpackage
package p2;
  import p1::*;
  function logic [7:0] g();
    return f();
  endfunction
endpackage
module top;
  import p2::*;
  int r_o;
  initial r_o = int'(g());
endmodule
