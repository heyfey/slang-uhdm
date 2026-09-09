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

// A9 — a CLASS in a package p3 that imports p2 THEN p1, calling f in a method.
package p3;
  import p2::*;
  import p1::*;
  class c;
    int r;
    function void m();
      r = f(1);
    endfunction
  endclass
endpackage

module top;
  int q;
  initial q = 0;
endmodule
