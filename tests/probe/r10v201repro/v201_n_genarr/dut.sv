// v201 arm N — the import copy under a GENERATE array and a parameter port
// list on the importer (defImpElabShape9's flip).
package p201vn;
  parameter N_A = 13;
  parameter N_B = N_A;
endpackage
module leaf201vn #(parameter LP = 1);
  import p201vn::*;
endmodule
module m201vn;
  genvar i;
  generate for (i = 0; i < 2; i++) begin : g
    leaf201vn #(.LP(i+1)) u();
  end endgenerate
endmodule
