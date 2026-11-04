// v12 — a VIRTUAL INTERFACE handle in the imported package, and the
// interface it names also imports the package (a cycle through a typespec).
package pv12;
  typedef virtual interface if_v12 vif12_t;
  int cv12 = 1;
endpackage

interface if_v12;
  import pv12::*;
  logic own_v12;
endinterface

module top_v12;
  if_v12 u_if();
endmodule
