// r10v108 v1 — THE ADMITTED-TYPE AXIS the implementer never witnessed.
// The patch admits SymbolKind::PredefinedIntegerType and ScalarType/Bit.
// g2_form108 golden-witnessed only bit / int / integer / byte / untyped.
// This arm holds the REST of that admitted set, plus reg/logic controls.
// MEASUREMENT ONLY.  The official uhdm-cmp is the sole judge.
package t108;
  typedef struct packed {
    logic [1:0] a;
    logic [1:0] b;
    logic [1:0] c;
    logic       d;
  } rsp_t;
  parameter rsp_t RSP = '{a: 2'b01, b: 2'b01, c: 2'b10, d: 1'b0};
endpackage

module ta108 #(parameter shortint        R = 0) (output logic [15:0] o); assign o = R; endmodule
module tb108 #(parameter longint         R = 0) (output logic [63:0] o); assign o = R; endmodule
module tc108 #(parameter time            R = 0) (output logic [63:0] o); assign o = R; endmodule
module td108 #(parameter int unsigned    R = 0) (output logic [31:0] o); assign o = R; endmodule
module te108 #(parameter byte unsigned   R = 0) (output logic  [7:0] o); assign o = R; endmodule
module tf108 #(parameter bit signed      R = 0) (output logic        o); assign o = R; endmodule
module tg108 #(parameter shortint unsigned R = 0)(output logic [15:0] o); assign o = R; endmodule
module th108 #(parameter longint unsigned  R = 0)(output logic [63:0] o); assign o = R; endmodule
module ti108 #(parameter integer signed  R = 0) (output logic [31:0] o); assign o = R; endmodule
// controls: `reg` is a ScalarType/Reg, `logic` a ScalarType/Logic -- both must DECLINE
module tj108 #(parameter reg             R = 0) (output logic        o); assign o = R; endmodule

module v1_types108
  import t108::*;
(
  output logic [15:0] oa, output logic [63:0] ob, output logic [63:0] oc,
  output logic [31:0] od, output logic  [7:0] oe, output logic        of,
  output logic [15:0] og, output logic [63:0] oh, output logic [31:0] oi,
  output logic        oj
);
  ta108 #(.R(RSP)) i_a (.o(oa));
  tb108 #(.R(RSP)) i_b (.o(ob));
  tc108 #(.R(RSP)) i_c (.o(oc));
  td108 #(.R(RSP)) i_d (.o(od));
  te108 #(.R(RSP)) i_e (.o(oe));
  tf108 #(.R(RSP)) i_f (.o(of));
  tg108 #(.R(RSP)) i_g (.o(og));
  th108 #(.R(RSP)) i_h (.o(oh));
  ti108 #(.R(RSP)) i_i (.o(oi));
  tj108 #(.R(RSP)) i_j (.o(oj));
endmodule
