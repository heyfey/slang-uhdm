// § cloneMintParentHomeCall253 (a member path receiver, a class property associative array)
package p;
  class holder;
    int seen[int];
  endclass
  function automatic int f(holder h, int k);
    if (h.seen.exists(k)) return 1;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
