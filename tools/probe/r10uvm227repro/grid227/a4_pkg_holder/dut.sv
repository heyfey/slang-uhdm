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

// A4 — a PACKAGE holder p3 that imports p2 THEN p1 and calls f in its own body.
package p3;
  import p2::*;
  import p1::*;
  function int g();
    return f(1);
  endfunction
endpackage

module top;
  import p3::*;
  int r;
  initial r = g();
endmodule
