// § pkgImpParamAliasColons210 — r11u217 p02: an alias of a VECTOR typedef (`typedef m_t n_t;`) typing an imported parameter, a signed vector typedef, and an enum-typed parameter, re-listed in an importing package read by the module
package a;
  typedef logic [3:0] m_t;
  typedef m_t n_t;
  typedef logic signed [5:0] s_t;
  typedef enum logic [1:0] { P, Q } e_t;
  parameter n_t NA = 4'b0110;
  parameter s_t SA = -6'sd3;
  parameter e_t EA = Q;
endpackage
package b;
  import a::*;
  parameter logic [3:0] LB = NA;
endpackage
module dut import b::*; (output logic [3:0] o);
  assign o = LB;
endmodule
