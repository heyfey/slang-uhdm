// v11u63 BREAKER GRID b1 — faces r11u63's g1/g2/g3 do NOT cover.
package pk63;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st_t;
  typedef union packed { logic [31:0] a; logic [31:0] b; } un_t;
  typedef struct packed { st_t inner; logic [31:0] c; } nest_t;
  st_t gv;                                   // package VARIABLE root
endpackage

module sink   (input  logic [31:0] a_i, output logic [31:0] o); assign o = a_i; endmodule
module sinkw  (input  logic [63:0] w_i, output logic [31:0] o); assign o = w_i[31:0]; endmodule
module sinkio (inout  wire  [31:0] a_i, output logic [31:0] o); assign o = 32'd0; endmodule

interface if63;
  pk63::st_t v;
  modport mp (input v);
endinterface

// b01 — HIERARCHICAL root (`tb.hv.a`): root name is NOT in parentNets
module b01 (output logic [31:0] o); sink u (.a_i(tb.hv.a), .o(o)); endmodule

// b02 — INTERFACE-INSTANCE root, member of the interface's struct
module b02 (output logic [31:0] o); if63 bi(); sink u (.a_i(bi.v.a), .o(o)); endmodule

// b03 — INTERFACE ARRAY element root
module b03 (output logic [31:0] o); if63 ba[2](); sink u (.a_i(ba[0].v.a), .o(o)); endmodule

// b04 — TYPE-PARAMETER root inside a FOR-GENERATE
module b04 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  for (genvar g = 0; g < 1; g++) begin : gb
    sink u (.a_i(pin.a), .o(o));
  end
endmodule

// b05 — TYPE-PARAMETER root, INSTANCE ARRAY connection
module b05 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  logic [31:0] oo [0:1];
  sink u [1:0] (.a_i(pin.a), .o(oo));
  assign o = oo[0];
endmodule

// b06 — TYPE-PARAMETER root, 3-DEEP nested member
module b06 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink u (.a_i(pin.inner.a), .o(o));
endmodule

// b07 — TYPE-PARAMETER root that is a UNION
module b07 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink u (.a_i(pin.a), .o(o));
endmodule

// b08 — REF-direction root (a var passed by ref is not a candidate; use a
//       plain var root but an INOUT sink port)
module b08 (output logic [31:0] o); pk63::st_t v; wire [31:0] w; assign w = v.a;
  sinkio u (.a_i(w), .o(o)); endmodule

// b09 — PACKAGE-VARIABLE root `pk63::gv.a`
module b09 (output logic [31:0] o); sink u (.a_i(pk63::gv.a), .o(o)); endmodule

// b10 — TYPE-PARAMETER root, UNPACKED ARRAY of the parameter type, element sel
module b10 #(parameter type T = logic) (input T pin [0:1], output logic [31:0] o);
  sink u (.a_i(pin[1].a), .o(o));
endmodule

// b11 — TYPE-PARAMETER root, member then BIT SELECT `pin.a[3]`
module b11 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink u (.a_i({31'd0, pin.a[3]}), .o(o));
endmodule

// b12 — TYPE-PARAMETER root, member inside a CONCAT actual
module b12 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sinkw u (.w_i({pin.a, pin.b}), .o(o));
endmodule

// b13 — TYPE-PARAMETER root, member inside a REPLICATION
module b13 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sinkw u (.w_i({2{pin.a}}), .o(o));
endmodule

// b14 — TYPE-PARAMETER root RE-PASSED two levels deep
module b14i #(parameter type T = logic) (input T pin, output logic [31:0] o);
  sink u (.a_i(pin.a), .o(o));
endmodule
module b14 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  b14i #(.T(T)) m (.pin(pin), .o(o));
endmodule

// b15 — TYPE-PARAMETER root inside an IF-GENERATE
module b15 #(parameter type T = logic) (input T pin, output logic [31:0] o);
  if (1) begin : ig
    sink u (.a_i(pin.a), .o(o));
  end
endmodule

// b16 — module instantiated INSIDE AN INTERFACE, struct-member actual
// b16 REMOVED: slang rejects a module instantiation inside an interface
//   (rc=3, "cannot instantiate a module in an interface") — an arm whose
//   compile fails teaches error recovery, not golden.
module b16 (output logic [31:0] o); assign o = 32'd0; endmodule

// b17 — WILDCARD `.*` connection, module whose port name IS a struct member
module sink_a (input logic [31:0] a, output logic [31:0] o); assign o = a; endmodule
module b17 (output logic [31:0] o);
  logic [31:0] a; assign a = 32'd7;
  sink_a u (.*, .o(o));
endmodule

// b18 — TERNARY actual with a TYPE-PARAMETER root on both arms
module b18 #(parameter type T = logic) (input T pin, input logic s, output logic [31:0] o);
  sink u (.a_i(s ? pin.a : pin.b), .o(o));
endmodule

// b19 — NAMED conn, root is an unpacked array of a TYPEDEF (no type param)
module b19 (output logic [31:0] o); pk63::st_t ua [0:1]; sink u (.a_i(ua[0].a), .o(o)); endmodule

// b20 — NAMED conn whose actual roots at a struct VAR declared in an enclosing
//       generate block, with a TYPE PARAMETER type
module b20 #(parameter type T = logic) (output logic [31:0] o);
  for (genvar g = 0; g < 1; g++) begin : og
    T gvv;
    sink u (.a_i(gvv.a), .o(o));
  end
endmodule

module tb;
  logic [31:0] o01,o02,o03,o04,o05,o06,o07,o08,o09,o10;
  logic [31:0] o11,o12,o13,o14,o15,o16,o17,o18,o19,o20;
  logic s; pk63::st_t hv; pk63::nest_t nv; pk63::un_t uv;
  pk63::st_t av [0:1];
  b01 i01 (.o(o01));
  b02 i02 (.o(o02));
  b03 i03 (.o(o03));
  b04 #(.T(pk63::st_t))  i04 (.pin(hv), .o(o04));
  b05 #(.T(pk63::st_t))  i05 (.pin(hv), .o(o05));
  b06 #(.T(pk63::nest_t)) i06 (.pin(nv), .o(o06));
  b07 #(.T(pk63::un_t))  i07 (.pin(uv), .o(o07));
  b08 i08 (.o(o08));
  b09 i09 (.o(o09));
  b10 #(.T(pk63::st_t))  i10 (.pin(av), .o(o10));
  b11 #(.T(pk63::st_t))  i11 (.pin(hv), .o(o11));
  b12 #(.T(pk63::st_t))  i12 (.pin(hv), .o(o12));
  b13 #(.T(pk63::st_t))  i13 (.pin(hv), .o(o13));
  b14 #(.T(pk63::st_t))  i14 (.pin(hv), .o(o14));
  b15 #(.T(pk63::st_t))  i15 (.pin(hv), .o(o15));
  b16 i16 (.o(o16));
  b17 i17 (.o(o17));
  b18 #(.T(pk63::st_t))  i18 (.pin(hv), .s(s), .o(o18));
  b19 i19 (.o(o19));
  b20 #(.T(pk63::st_t))  i20 (.o(o20));
endmodule
