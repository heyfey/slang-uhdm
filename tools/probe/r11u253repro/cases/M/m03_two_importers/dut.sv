// § cloneMintParentHomeCall253
package p;
  class keep_c; endclass
  function automatic int f(int k);
    int seen[int];
    if (seen.exists(k)) return 1;
    return 0;
  endfunction
endpackage
package q1;
  import p::*;
endpackage
package q2;
  import p::*;
endpackage
module top;
  import q1::*;
endmodule
