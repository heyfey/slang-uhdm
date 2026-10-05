// § pkgListingWinsFlatLocal238v
// an out-of-body constructor's block-item local is hoisted into the package listing;
// a paren-less method's same-named local then loses to it in Surelog's late binder
package p;
  class c;
    extern function new();
    extern function void m_set;
  endclass
  function c::new();
    string vals[$];
    vals.push_back("a");
  endfunction
  function void c::m_set;
    static string vals[$];
    string t[$];
    foreach (vals[i]) t.push_back(vals[i]);
  endfunction
endpackage
module top;
endmodule
