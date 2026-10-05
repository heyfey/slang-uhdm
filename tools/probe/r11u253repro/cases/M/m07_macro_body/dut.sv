// § cloneMintParentHomeCall253
`define CHK(A, K) if (A.exists(K)) return 1;
package p;
  class keep_c; endclass
  function automatic int f(int k);
    int seen[int];
    `CHK(seen, k)
    `CHK(seen, k)
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
