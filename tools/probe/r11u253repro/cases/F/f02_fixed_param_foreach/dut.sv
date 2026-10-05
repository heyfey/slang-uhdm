// § cloneTfFixedArrTsParented253
package p;
  class keep_c; endclass
  parameter N = 3;
  function automatic int f(int k);
    logic [7:0] shelf[N];
    foreach (shelf[i]) shelf[i] = k;
    return shelf[0];
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
