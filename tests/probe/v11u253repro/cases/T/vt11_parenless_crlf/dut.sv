// § cloneTfItemLocalOwnVar253 (CRLF)
package p;
  function automatic int f;
    int x;
    x = 5;
    return x;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
