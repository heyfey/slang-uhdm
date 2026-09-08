// verifier arm 4 — parameter defaults inside a package CLASS body
// (the class_defn listing kind the corpus head actually lands in).
package v4pkg;
  parameter P_LIT = 5;
  class v4cls;
    parameter C_LIT = 7;
    parameter C_REF = C_LIT;
    parameter C_PKGREF = P_LIT;
    localparam C_LOC = C_REF;
  endclass
endpackage
module v4mod;
  import v4pkg::*;
endmodule
