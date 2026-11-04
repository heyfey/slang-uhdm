// § pkgEnumAliasListingParent212 — a package typedef aliasing a package enum typedef, used as a package function's formal (BuildUVMPkg's UVM_SEQ_ARB_TYPE)
package p;
  typedef enum { A, B, C } e_t;
  typedef e_t f_t;
  function automatic int g(f_t v); return int'(v); endfunction
endpackage
module dut(input logic i, output logic o);
  assign o = i;
endmodule
