// r10uvm227 grid arm — MEASUREMENT ONLY.  p1 DEFINES the free function `f`;
// p2 WILDCARD-IMPORTS p1, so p2 LISTS a clone of `f` (our own
// § collectPkgTfListing law, and Surelog copies the same listing).  `f` has a
// LOCAL so the two clone shapes are distinguishable, exactly as
// uvm_report_enabled`s `cs` is.
package p1;
  function int f(int a);
    int loc;
    loc = a;
    return loc + 1;
  endfunction
endpackage

package p2;
  import p1::*;
  int p2v = 1;
endpackage

// A10 — the SAME bare call in four CONTEXTS inside one interface.
interface ifc();
  import p2::*;
  import p1::*;
  int r1, r2, r3;
  wire [31:0] w;
  initial r1 = f(1);
  always_comb r2 = f(2);
  assign w = f(3);
  function int h();
    return f(4);
  endfunction
endinterface

module top;
  int q;
  initial q = 0;
endmodule
