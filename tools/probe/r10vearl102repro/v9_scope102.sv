// v9_scope102 -- scope faces the law's guard must classify: a $unit-scope
// unpacked-array parameter, a package array reached WITHOUT import (scoped
// reference), a package array inside a GENERATE-FOR instance span, and an
// INSTANCE ARRAY of one module.
parameter int UN = 3;
parameter int UARR [0:UN-1] = '{1,2,3};        // $unit home -- NOT a package

package v9p102;
  parameter int PN = 3;
  parameter int PARR [0:PN-1] = '{1,2,3};
endpackage

module v9leaf102;
  import v9p102::*;
  int t = PARR[0] + UARR[0];
endmodule

module v9noimp102;
  int t = v9p102::PARR[0];                     // scoped, no import
endmodule

module v9_scope102;
  v9leaf102 u_arr [0:2] ();                    // instance ARRAY
  v9noimp102 u_n();
  for (genvar gi = 0; gi < 3; gi++) begin : g_loop
    v9leaf102 u_g();                           // generate-for span, 3 copies
  end
endmodule
