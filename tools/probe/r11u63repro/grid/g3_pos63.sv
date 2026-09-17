// r11u63 g3 — THE POSITIONAL AXIS, on roots the typedef registry cannot answer.
package r63;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st_t;
endpackage
module sink_i (input logic [31:0] a_i, output logic [31:0] o); assign o = a_i; endmodule
// p01 NAMED   + typedef root          (control: golden attaches)
module p01 (output logic [31:0] o); r63::st_t v; sink_i u (.a_i(v.a), .o(o)); endmodule
// p02 POSITIONAL + typedef root        (golden?)
module p02 (output logic [31:0] o); r63::st_t v; sink_i u (v.a, o); endmodule
// p03 NAMED   + TYPE-PARAMETER port root
module p03 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink_i u (.a_i(pin.a), .o(o)); endmodule
// p04 POSITIONAL + TYPE-PARAMETER port root
module p04 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink_i u (pin.a, o); endmodule
// p05 NAMED   + ANONYMOUS struct root
module p05 (output logic [31:0] o);
  struct packed { logic [31:0] a; logic [31:0] b; } anon; sink_i u (.a_i(anon.a), .o(o)); endmodule
// p06 POSITIONAL + ANONYMOUS struct root
module p06 (output logic [31:0] o);
  struct packed { logic [31:0] a; logic [31:0] b; } anon; sink_i u (anon.a, o); endmodule
// p07 MIXED: the instance has one positional and one named conn is illegal, so
//      a SECOND positional instance of the same module, member in a CONCAT
module sink_w (input logic [63:0] w_i, output logic [31:0] o); assign o = w_i[31:0]; endmodule
module p07 (output logic [31:0] o); r63::st_t v; sink_w u ({v.a, v.b}, o); endmodule
module tb;
  logic [31:0] o1,o2,o3,o4,o5,o6,o7; r63::st_t topv;
  p01 i1 (.o(o1));
  p02 i2 (.o(o2));
  p03 #(.T(r63::st_t)) i3 (.pin(topv), .o(o3));
  p04 #(.T(r63::st_t)) i4 (.pin(topv), .o(o4));
  p05 i5 (.o(o5));
  p06 i6 (.o(o6));
  p07 i7 (.o(o7));
endmodule
