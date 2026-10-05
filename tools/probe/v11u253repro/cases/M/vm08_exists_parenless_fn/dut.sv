// § cloneMintParentHomeCall253 (a paren-less function: the tf-item local array)
package p;
  class keep_c; endclass
  function automatic int f;
    int seen[int];
    int k;
    k = 3;
    if (seen.exists(k)) return 1;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
