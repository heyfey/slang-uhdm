// r11u63 g1 — the ELABORATED PORT-CONNECTION hier_path's ref_typespec:
// root kinds x member kinds x directions x holders x views x neighbour roads.
package p63;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st_t;
  typedef union  packed { logic [31:0] u0; logic [31:0] u1; } un_t;
  typedef struct packed { st_t inner; logic [31:0] tag; } nest_t;
  typedef st_t arr_t [0:1];
  typedef struct packed { logic [31:0] q; logic [31:0] r; } el_t;
endpackage

module sink_i (input  logic [31:0] a_i, output logic [31:0] o); assign o = a_i; endmodule
module sink_o (output logic [31:0] a_o, output logic [31:0] o); assign a_o = 32'd1; assign o = 32'd2; endmodule
module sink_w (input  logic [63:0] w_i, output logic [31:0] o); assign o = w_i[31:0]; endmodule

// c01 module-scope struct VAR root, input direction
module h01 (output logic [31:0] o);
  p63::st_t v; sink_i u (.a_i(v.a), .o(o));
endmodule
// c02 module-scope struct NET root
module h02 (output logic [31:0] o);
  wire p63::st_t n; sink_i u (.a_i(n.a), .o(o));
endmodule
// c03 UNION root
module h03 (output logic [31:0] o);
  p63::un_t v; sink_i u (.a_i(v.u0), .o(o));
endmodule
// c04 NESTED member (two hops)
module h04 (output logic [31:0] o);
  p63::nest_t v; sink_i u (.a_i(v.inner.a), .o(o));
endmodule
// c05 the ROOT IS A PORT of the holder
module h05 (input p63::st_t pin, output logic [31:0] o);
  sink_i u (.a_i(pin.a), .o(o));
endmodule
// c06 the ROOT IS A PORT typed by a TYPE PARAMETER  <- the R0 face
module h06 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink_i u (.a_i(pin.a), .o(o));
endmodule
// c07 gen-local root
module h07 (output logic [31:0] o);
  if (1) begin : g
    p63::st_t gv; sink_i u (.a_i(gv.a), .o(o));
  end
endmodule
// c08 OUTPUT direction actual
module h08 (output logic [31:0] o);
  p63::st_t v; sink_o u (.a_o(v.a), .o(o));
endmodule
// c09 inside a CONCAT
module h09 (output logic [31:0] o);
  p63::st_t v; sink_w u (.w_i({v.a, v.b}), .o(o));
endmodule
// c10 inside a BINARY op
module h10 (output logic [31:0] o);
  p63::st_t v; sink_i u (.a_i(v.a & v.b), .o(o));
endmodule
// c11 mid-path ELEMENT SELECT on an unpacked array of structs
module h11 (output logic [31:0] o);
  p63::arr_t av; sink_i u (.a_i(av[1].a), .o(o));
endmodule
// c12 ANONYMOUS struct root (no typedef)
module h12 (output logic [31:0] o);
  struct packed { logic [31:0] a; logic [31:0] b; } anon; sink_i u (.a_i(anon.a), .o(o));
endmodule
// c13 the ROOT IS A LOCALPARAM of struct type (param_assign road)
module h13 (output logic [31:0] o);
  localparam p63::st_t LP = '{a: 32'd7, b: 32'd8};
  sink_i u (.a_i(LP.a), .o(o));
endmodule
// c14 NEIGHBOUR ROAD: the same member read in a CONT_ASSIGN Rhs
module h14 (output logic [31:0] o);
  p63::st_t v; assign o = v.a;
endmodule
// c15 NEIGHBOUR ROAD: the same member read inside an ALWAYS block
module h15 (output logic [31:0] o);
  p63::st_t v; logic [31:0] r; always_comb r = v.a; assign o = r;
endmodule
// c16 NEIGHBOUR ROAD: the same member read in a PARAM initialiser
module h16 (output logic [31:0] o);
  localparam p63::st_t LP = '{a: 32'd9, b: 32'd10};
  localparam logic [31:0] Q = LP.a;
  assign o = Q;
endmodule
// c17 the connection is inside a GENERATE block, root at MODULE scope
module h17 (output logic [31:0] o);
  p63::st_t v;
  if (1) begin : g  sink_i u (.a_i(v.a), .o(o)); end
endmodule
// c18 INSTANCE ARRAY connection
module h18 (output logic [31:0] o);
  p63::st_t v; logic [31:0] oo [0:1];
  sink_i u [0:1] (.a_i(v.a), .o(oo));
  assign o = oo[0];
endmodule
// c19 the actual is a TERNARY
module h19 (input logic c, output logic [31:0] o);
  p63::st_t v; sink_i u (.a_i(c ? v.a : v.b), .o(o));
endmodule
// c20 the root is an unpacked-array var of a TYPEDEF'd element (array_typespec)
module h20 (output logic [31:0] o);
  p63::el_t ea [0:1]; sink_i u (.a_i(ea[0].q), .o(o));
endmodule

module tb;
  logic [31:0] o01,o02,o03,o04,o05,o06,o07,o08,o09,o10;
  logic [31:0] o11,o12,o13,o14,o15,o16,o17,o18,o19,o20;
  p63::st_t topv;
  h01 i01 (.o(o01));
  h02 i02 (.o(o02));
  h03 i03 (.o(o03));
  h04 i04 (.o(o04));
  h05 i05 (.pin(topv), .o(o05));
  h06 #(.T(p63::st_t)) i06 (.pin(topv), .o(o06));
  h07 i07 (.o(o07));
  h08 i08 (.o(o08));
  h09 i09 (.o(o09));
  h10 i10 (.o(o10));
  h11 i11 (.o(o11));
  h12 i12 (.o(o12));
  h13 i13 (.o(o13));
  h14 i14 (.o(o14));
  h15 i15 (.o(o15));
  h16 i16 (.o(o16));
  h17 i17 (.o(o17));
  h18 i18 (.o(o18));
  h19 i19 (.c(1'b1), .o(o19));
  h20 i20 (.o(o20));
endmodule
