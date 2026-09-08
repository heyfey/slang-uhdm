// r10v205 arm K — THE MODULE CONTEXT and the EXPLICIT-import face together.
// A module wildcard-imports the clone package (so the clone bodies exist), an
// INTERFACE wildcard-imports the declaring package directly, and a second
// module imports one NAME explicitly.  Names golden leaves QUALIFIED in a
// module/interface home listing must stay qualified.
package p205a_k2;
  typedef bit [7:0] bt205;
  typedef logic [3:0] lt205;
  function automatic int fk205(input bt205 kio205[]);
    bt205 kloc205[];
    lt205 klog205[];
    return kio205.size() + kloc205.size() + klog205.size();
  endfunction
endpackage

package p205b_k2;
  import p205a_k2::*;
  function automatic int gk205();
    bt205 z205[];
    return fk205(z205);
  endfunction
endpackage

interface v205_k_if;
  import p205a_k2::*;
  bt205 ifarr205[];
  lt205 iflog205[];
endinterface

module v205_k_expl;
  import p205a_k2::bt205;
  import p205a_k2::fk205;
  bt205 xarr205[];
  int r205;
  initial r205 = fk205(xarr205);
endmodule

module v205_k_modctx;
  import p205b_k2::*;
  import p205a_k2::*;
  bt205 marr205[];
  lt205 mlog205[];
  v205_k_if u205();
  v205_k_expl x205();
  int r205;
  initial r205 = gk205() + marr205.size() + mlog205.size();
endmodule
