// § cloneMintParentHomeCall253 (delete and first and next with a bare argument)
package p;
  class keep_c; endclass
  function automatic int f(int k);
    int a[int];
    int i;
    a[k] = 1;
    a.delete(k);
    void'(a.first(i));
    void'(a.next(i));
    return i;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
