// § cloneMintParentHomeCall253 (two receivers on one line, different arrays)
package p;
  class keep_c; endclass
  function automatic int f(int k);
    int a[int]; int b[int];
    if (a.exists(k) && b.exists(k)) return 1;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
