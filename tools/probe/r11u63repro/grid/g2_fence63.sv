// r11u63 g2 — THE FENCES: root kinds the arm must DECLINE, directions and
// depths it must still take, and the neighbour roads it must not touch.
package q63;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st_t;
  typedef enum logic [1:0] { E0, E1 } e_t;
  typedef struct packed { e_t e; logic [29:0] pad; } est_t;
  typedef logic [1:0][31:0] pk_t;
  st_t PKGV = '{a: 32'd1, b: 32'd2};
endpackage

interface ifc63; q63::st_t req; modport mp (input req); endinterface

module sink_i (input logic [31:0] a_i, output logic [31:0] o); assign o = a_i; endmodule
module sink_b (inout  wire  [31:0] b_io, output logic [31:0] o); assign o = 32'd3; endmodule

// f01 INOUT direction
module f01 (output logic [31:0] o);
  wire q63::st_t v; sink_b u (.b_io(v.a), .o(o));
endmodule
// f02 POSITIONAL connection
module f02 (output logic [31:0] o);
  q63::st_t v; sink_i u (v.a, o);
endmodule
// f03 re-passed ONE DEEPER (the actual is the holder's own port member)
module f03mid (input q63::st_t pin, output logic [31:0] o);
  sink_i u (.a_i(pin.a), .o(o));
endmodule
module f03 (output logic [31:0] o);
  q63::st_t v; f03mid m (.pin(v), .o(o));
endmodule
// f04 INTERFACE-PORT root (plain)
module f04sub (input logic [31:0] a_i, output logic [31:0] o); assign o = a_i; endmodule
module f04mid (ifc63 conn, output logic [31:0] o);
  f04sub u (.a_i(conn.req.a), .o(o));
endmodule
module f04 (output logic [31:0] o);
  ifc63 c (); f04mid m (.conn(c), .o(o));
endmodule
// f05 MODPORT-qualified interface root
module f05mid (ifc63.mp sub, output logic [31:0] o);
  f04sub u (.a_i(sub.req.a), .o(o));
endmodule
module f05 (output logic [31:0] o);
  ifc63 c (); f05mid m (.sub(c.mp), .o(o));
endmodule
// f06 PACKAGE-scoped variable root
module f06 (output logic [31:0] o);
  sink_i u (.a_i(q63::PKGV.a), .o(o));
endmodule
// f07 ENUM-membered struct root
module f07 (output logic [31:0] o);
  q63::est_t v; sink_i u (.a_i({30'd0, v.e}), .o(o));
endmodule
// f08 PACKED-ARRAY typedef root, element select (no member at all)
module f08 (output logic [31:0] o);
  q63::pk_t v; sink_i u (.a_i(v[1]), .o(o));
endmodule
// f09 the root is a FUNCTION-local (never reachable from a connection)
module f09 (output logic [31:0] o);
  function automatic logic [31:0] f (); q63::st_t lv; f = lv.a; endfunction
  assign o = f();
endmodule
// f10 DEEP member chain through two structs, inside a concat, output direction
module f10sub (output logic [63:0] w_o, output logic [31:0] o);
  assign w_o = 64'd0; assign o = 32'd4;
endmodule
module f10 (output logic [31:0] o);
  q63::st_t v; logic [63:0] w; f10sub u (.w_o(w), .o(o));
  assign w = {v.a, v.b};
endmodule
// f11 a root DECLARED IN A GENERATE BLOCK, connection in the SAME block
module f11 (output logic [31:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    q63::st_t gv; sink_i u (.a_i(gv.a), .o(o));
  end
endmodule
// f12 a root declared in an ENCLOSING generate block, connection NESTED
module f12 (output logic [31:0] o);
  if (1) begin : g0
    q63::st_t gv;
    if (1) begin : g1
      sink_i u (.a_i(gv.a), .o(o));
    end
  end
endmodule

module tb;
  logic [31:0] o01,o02,o03,o04,o05,o06,o07,o08,o09,o10,o11,o12;
  f01 i01 (.o(o01));
  f02 i02 (.o(o02));
  f03 i03 (.o(o03));
  f04 i04 (.o(o04));
  f05 i05 (.o(o05));
  f06 i06 (.o(o06));
  f07 i07 (.o(o07));
  f08 i08 (.o(o08));
  f09 i09 (.o(o09));
  f10 i10 (.o(o10));
  f11 i11 (.o(o11));
  f12 i12 (.o(o12));
endmodule
