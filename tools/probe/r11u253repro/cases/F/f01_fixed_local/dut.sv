// § cloneTfFixedArrTsParented253
package p;
  class keep_c; endclass
  function automatic int f(int k);
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
