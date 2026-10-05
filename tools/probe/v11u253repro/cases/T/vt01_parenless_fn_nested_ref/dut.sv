// § cloneTfItemLocalOwnVar253 (a subroutine-level local read from a nested begin)
package p;
  function automatic int f;
    int x;
    int y;
    x = 1;
    begin
      int z;
      z = x;
      y = z + x;
    end
    return y;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
