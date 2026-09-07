// r10uvm194 arm C — THE CLONE AXIS.  A package that WILDCARD-IMPORTS the home
// carries a CLONE of the home's whole listing (§ collectPkgTfListing), and
// § classRetNameDefViewNoBind37 unbinds the clone's copies too
// (`pkgImportCloneTfs16`).  This arm reads a REAL Surelog golden for the clone
// copies so the exemption is FENCED by measurement rather than by symmetry.
package c194_src;
  class C194;
    extern function string c_out();
  endclass
  function string C194::c_out();
    int i; i=0;
    c_out = {c_out," "};
    c_out[i] = 8'h41;
  endfunction
  function string c_free();
    int i; i=0;
    c_free = {c_free," "};
    c_free[i] = 8'h42;
  endfunction
endpackage

package c194_clone;
  import c194_src::*;
  function int c_drive();
    C194 h = new();
    string a1 = h.c_out();
    string a2 = c_free();
    return a1.len() + a2.len();
  endfunction
endpackage

module c194_top;
  import c194_clone::*;
  int r;
  initial r = c_drive();
endmodule
