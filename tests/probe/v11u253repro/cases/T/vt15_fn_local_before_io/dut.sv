// § cloneTfItemLocalOwnVar253 (a paren-less function: a local declared before the io)
package p;
  function automatic int f;
    int x;
    input int a;
    x = a;
    return x;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
