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

// A12 — the call written inside p2's OWN body (p2 imports p1 and calls f).
package p2b;
  import p1::*;
  function int g2();
    return f(1);
  endfunction
endpackage

module top;
  import p2b::*;
  int r;
  initial r = g2();
endmodule
