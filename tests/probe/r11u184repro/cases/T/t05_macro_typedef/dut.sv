// § tpEnumCopyAtTypedef184: an enum typedef written by a macro from an included file, passed as a type parameter
`include "defs.svh"
module sub #(parameter type T = logic [1:0]) (input T si, output T so);
  assign so = si;
endmodule
module top(input logic [1:0] a, output logic [1:0] b);
  `MK_ENUM(m_e)
  m_e x, y;
  assign x = m_e'(a);
  sub #(.T(m_e)) u (.si(x), .so(y));
  assign b = y;
endmodule
