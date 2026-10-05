// § cloneTfFixedArrTsParented253
package p;
  class c;
    extern function int f(int k);
  endclass
  function int c::f(int k);
    int shelf[4];
    shelf[0] = k;
    return shelf[0];
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
