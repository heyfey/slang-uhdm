// § cloneMintParentHomeCall253 (an exporting importer, a second-level importer)
package p;
  class keep_c; endclass
  function automatic int f(int k);
    int seen[int];
    if (seen.exists(k)) return 1;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
  export p::*;
endpackage
package r;
  import q::*;
endpackage
module top;
  import r::*;
endmodule
