// § pkgExportItemReImports471
// exported enum-typed and typedef-typed parameters
package a;
  typedef enum logic [1:0] {M0, M1, M2} m_t;
  typedef logic [7:0] byte_t;
  parameter m_t PM = M2;
  parameter byte_t PY = 8'hA5;
endpackage
package b;
  import a::*;
  export a::*;
  parameter int QB = 1;
endpackage
module top(output logic [7:0] y);
  import b::*;
  assign y = 8'd0;
endmodule
