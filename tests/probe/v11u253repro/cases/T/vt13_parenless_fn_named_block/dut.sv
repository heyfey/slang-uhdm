// § cloneTfItemLocalOwnVar253 (a named block with its own local and a reference to the subroutine local)
package p;
  function automatic int f;
    int x;
    x = 1;
    begin : blk
      int x2;
      x2 = x;
      x = x2 + 1;
    end
    return x;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
