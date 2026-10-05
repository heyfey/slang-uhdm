// § selFold9 (decode only, ground A: Earlgrey_0_1 #154375 / #165002, a port high-conn select index folded from an imported parameter: the stamped ref_typespec named with the port)
package pk;
  parameter int unsigned PMP_I = 0;
endpackage
module sub (input logic a);
endmodule
module top;
  import pk::*;
  logic [2:0] pmp_req_err;
  sub u (.a(pmp_req_err[PMP_I]));
endmodule
