// § cloneMintParentHomeCall253 (control: a module import makes no copy)
package p;
  function automatic int f(int k);
    int seen[int];
    if (seen.exists(k)) return 1;
    return 0;
  endfunction
endpackage
module top;
  import p::*;
  int r;
  initial r = f(1);
endmodule
