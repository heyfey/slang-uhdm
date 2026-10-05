// § cloneTfItemLocalOwnVar253 (static locals with initializers that read each other)
package p;
  function int f;
    static int a = 4;
    int b;
    b = a;
    a = b + 1;
    return a;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
