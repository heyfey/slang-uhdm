// § importCopyTsInstByRole469
// a packed 2-D typedef parameter
package a;
  typedef logic [1:0][3:0] m_t;
  parameter m_t PM = 8'h5a;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
