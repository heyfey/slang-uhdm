// § cloneMintParentHomeCall253
package p;
  class keep_c; endclass
  function automatic int f(int k, int j);
    int a[int]; int b[int];
    if (a.exists(k) && b.exists(j)) return 1;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
