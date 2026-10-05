// § cloneMintParentHomeCall253 (in a foreach body, the argument the loop variable)
package p;
  class keep_c; endclass
  function automatic int f(int q[$]);
    int seen[int];
    int n = 0;
    foreach (q[i]) if (!seen.exists(q[i])) n++;
    foreach (q[j]) begin int v; v = q[j]; if (seen.exists(v)) n--; end
    return n;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
