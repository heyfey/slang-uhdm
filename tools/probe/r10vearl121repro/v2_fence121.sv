// r10vearl121 FENCE: cells the law must NOT touch.  Pristine and patched dumps
// must be byte-identical in BOTH views.
package fp121;
  typedef struct packed { logic a; logic [3:0] b; logic [7:0] c; } s_t;
  typedef struct        { logic a; logic [3:0] b; }               u_t;   // UNPACKED
  typedef union  packed { logic [12:0] w; s_t s; }                un_t;
endpackage

module vfence121 (
  input  logic [7:0] din,
  output logic [12:0] o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12
);
  import fp121::*;
  s_t f1;          // MODULE-scope target written from a gen scope
  s_t f2;          // NAMESAKE at module scope
  s_t f4arr [2];   // module-scope unpacked array (bit_select Lhs)
  s_t f8;          // module-scope cont_assign
  s_t f9;
  un_t f14;

  // f1 -- module-scope target written from inside a generate block
  for (genvar i = 0; i < 1; i++) begin : g1
    assign f1 = '{a: 1'b1, b: 4'd1, c: din};
  end
  assign o1 = f1;

  // f2 -- gen-local target whose NAME is also a module-body variable
  for (genvar i = 0; i < 1; i++) begin : g2
    s_t f2;
    assign f2 = '{a: 1'b0, b: 4'd2, c: din};
  end
  assign o2 = g2[0].f2 ^ f2;

  // f4 -- bit_select Lhs on a MODULE-scope unpacked array
  for (genvar i = 0; i < 1; i++) begin : g4
    assign f4arr[i] = '{a: 1'b1, b: 4'd4, c: din};
  end
  assign o4 = f4arr[0];

  // f5 -- MEMBER (hier_path) Lhs on a gen-local struct
  for (genvar i = 0; i < 1; i++) begin : g5
    struct packed { logic v; s_t lo; } f5;
    assign f5.lo = '{a: 1'b1, b: 4'd5, c: din};
    assign f5.v  = 1'b0;
  end
  assign o5 = g5[0].f5.lo;

  // f6 -- POSITIONAL pattern, gen-local whole-name target
  for (genvar i = 0; i < 1; i++) begin : g6
    s_t f6;
    assign f6 = '{1'b1, 4'd6, din};
  end
  assign o6 = g6[0].f6;

  // f7 -- REPLICATED pattern, gen-local whole-name target
  for (genvar i = 0; i < 1; i++) begin : g7
    logic [12:0] f7;
    assign f7 = {13{1'b1}};
  end
  assign o7 = g7[0].f7;

  // f8 -- MODULE-scope continuous assign with a keyed pattern
  assign f8 = '{a: 1'b0, b: 4'd8, c: din};
  assign o8 = f8;

  // f9 -- always_comb with a keyed pattern
  always_comb f9 = '{a: 1'b1, b: 4'd9, c: din};
  assign o9 = f9;

  // f10 -- gen-scope localparam initialised from a keyed pattern
  for (genvar i = 0; i < 1; i++) begin : g10
    localparam s_t LP = '{a: 1'b1, b: 4'd10, c: 8'd10};
    s_t f10;
    assign f10 = LP;
  end
  assign o10 = g10[0].f10;

  // f11 -- gen-local UNPACKED struct target (not a packed struct)
  for (genvar i = 0; i < 1; i++) begin : g11
    u_t f11;
    assign f11 = '{a: 1'b1, b: 4'd11};
  end
  assign o11 = {8'd0, g11[0].f11.b, g11[0].f11.a};

  // f12 -- gen-local PACKED UNION target
  for (genvar i = 0; i < 1; i++) begin : g12
    un_t f12;
    assign f12 = un_t'(13'd12);
  end
  assign o12 = g12[0].f12.w;

  // f3 -- gen-local target, EXPLICIT CAST pattern
  for (genvar i = 0; i < 1; i++) begin : g3
    s_t f3;
    assign f3 = s_t'{a: 1'b1, b: 4'd3, c: din};
  end
  assign o3 = g3[0].f3;
endmodule
