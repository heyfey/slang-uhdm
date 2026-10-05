// § cloneTfFixedArrTsParented253
package p;
  class keep_c; endclass
  function automatic int f(int k);
    int shelf[2][3];
    shelf[0][1] = k;
    return shelf[0][1];
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
