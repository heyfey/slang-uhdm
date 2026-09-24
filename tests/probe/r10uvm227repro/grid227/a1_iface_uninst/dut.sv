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

// A1 — an UNINSTANTIATED interface, imports p2 THEN p1, bare call in initial.
interface ifc();
  import p2::*;
  import p1::*;
  int r;
  initial begin
    r = f(1);
  end
endinterface

module top;
  int q;
  initial q = 0;
endmodule
