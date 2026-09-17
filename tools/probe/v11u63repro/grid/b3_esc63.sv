// v11u63 BREAKER GRID b3 — ESCAPED-IDENTIFIER roots (the documented trap of
// bindConnPathRootTs53's longest-match root finder), plus the remaining shapes.
package ek63;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st_t;
endpackage
module sink (input logic [31:0] a_i, output logic [31:0] o); assign o = a_i; endmodule
module sinkw (input logic [63:0] w_i, output logic [31:0] o); assign o = w_i[31:0]; endmodule

// e01 — ESCAPED root containing a DOT, type from a TYPE PARAMETER
module e01 #(parameter type T = logic) (input T \pin.i , output logic [31:0] o);
  sink u (.a_i(\pin.i .a), .o(o));
endmodule

// e02 — ESCAPED root containing a BRACKET, TYPE PARAMETER
module e02 #(parameter type T = logic) (input T \p[0] , output logic [31:0] o);
  sink u (.a_i(\p[0] .a), .o(o));
endmodule

// e03 — an escaped root and a PLAIN root of the same head in ONE concat
module e03 #(parameter type T = logic) (input T a, input T \a.b , output logic [31:0] o);
  sinkw u (.w_i({a.a, \a.b .a}), .o(o));
endmodule

// e04 — ANONYMOUS-struct root inside an IF-GENERATE
module e04 (output logic [31:0] o);
  if (1) begin : g
    struct packed { logic [31:0] a; logic [31:0] b; } an;
    sink u (.a_i(an.a), .o(o));
  end
endmodule

// e05 — TYPE-PARAMETER root, connection in a NESTED generate (for in if)
module e05 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  if (1) begin : og
    for (genvar g = 0; g < 1; g++) begin : ig
      sink u (.a_i(pin.a), .o(o));
    end
  end
endmodule

// e06 — TYPE-PARAMETER root whose specialization is an ANONYMOUS struct
module e06 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink u (.a_i(pin.a), .o(o));
endmodule

// e07 — the SAME formal connected NAMED on one instance and the module also
//       instantiated POSITIONALLY elsewhere (fence must be per connection)
module e07 (output logic [31:0] o);
  ek63::st_t v; logic [31:0] o1, o2;
  sink un (.a_i(v.a), .o(o1));
  sink up (v.b, o2);
  assign o = o1 ^ o2;
endmodule

module tb;
  logic [31:0] o1,o2,o3,o4,o5,o6,o7;
  ek63::st_t ev, ev2, ev3;
  struct packed { logic [31:0] a; logic [31:0] b; } anontop;
  e01 #(.T(ek63::st_t)) i1 (.\pin.i (ev), .o(o1));
  e02 #(.T(ek63::st_t)) i2 (.\p[0] (ev), .o(o2));
  e04 i4 (.o(o4));
  e05 #(.T(ek63::st_t)) i5 (.pin(ev2), .o(o5));
  e06 #(.T(type(anontop))) i6 (.pin(anontop), .o(o6));
  e03 #(.T(ek63::st_t)) i3 (.a(ev), .\a.b (ev3), .o(o3));
  e07 i7 (.o(o7));
endmodule
