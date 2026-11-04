// § cloneTfItemLocalOwnVar253 (a paren-less function with one statement)
package p;
  function automatic int f;
    int x = 3;
    return x;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
