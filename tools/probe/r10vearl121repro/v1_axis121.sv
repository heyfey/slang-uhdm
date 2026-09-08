// r10vearl121 adversarial IN-WINDOW axis: gen-local whole-name PACKED-STRUCT
// target, KEYED assignment pattern, gen-scope continuous assign, DEFAULT view.
// Golden (Surelog -parse) must keep the tagged_pattern wrappers on every cell.
package vp121;
  typedef struct packed {
    logic       a;
    logic [3:0] b;
    logic [7:0] c;
  } s_t;
  typedef struct packed {
    logic [1:0] x;
    s_t         y;
  } n_t;
  function automatic logic [7:0] f8(input logic [7:0] v);
    f8 = v + 8'd1;
  endfunction
endpackage

module vaxis121 #(parameter int M = 2) (
  input  logic [7:0] din,
  input  logic       sel,
  output logic [12:0] o1,
  output logic [12:0] o2,
  output logic [12:0] o3,
  output logic [12:0] o4,
  output logic [12:0] o5,
  output logic [12:0] o6,
  output logic [12:0] o7,
  output logic [14:0] o8,
  output logic [12:0] o9,
  output logic [12:0] o10,
  output logic [12:0] o11,
  output logic [12:0] o12,
  output logic [12:0] o13,
  output logic  [3:0] o15,
  output logic [12:0] o16,
  output logic [12:0] o17,
  output logic [12:0] o18a,
  output logic [12:0] o18b,
  output logic [12:0] o19,
  output logic [12:0] o20
);
  import vp121::*;
  typedef struct packed { logic [3:0] q; } one_t;
  localparam int PK = 3;
  parameter int c13 = 5;     // NAMESAKE that is a PARAMETER, not a var/net

  // c1 -- baseline: for-generate, gen-local target
  for (genvar i = 0; i < 1; i++) begin : g1
    s_t c1;
    assign c1 = '{a: 1'b1, b: 4'd3, c: 8'd7};
  end
  assign o1 = g1[0].c1;

  // c2 -- if-generate
  if (M > 0) begin : g2
    s_t c2;
    assign c2 = '{a: 1'b0, b: 4'd5, c: din};
  end
  assign o2 = g2.c2;

  // c3 -- nested for-generate, target in the INNER block
  for (genvar i = 0; i < 1; i++) begin : g3o
    for (genvar j = 0; j < 1; j++) begin : g3i
      s_t c3;
      assign c3 = '{a: 1'b1, b: 4'(j), c: din};
    end
  end
  assign o3 = g3o[0].g3i[0].c3;

  // c4 -- target declared in the OUTER gen block, assigned from the INNER one
  for (genvar i = 0; i < 1; i++) begin : g4o
    s_t c4;
    for (genvar j = 0; j < 1; j++) begin : g4i
      assign c4 = '{a: 1'b0, b: 4'd1, c: din};
    end
  end
  assign o4 = g4o[0].c4;

  // c5 -- ANONYMOUS packed struct declared gen-locally
  for (genvar i = 0; i < 1; i++) begin : g5
    struct packed { logic a; logic [3:0] b; logic [7:0] c; } c5;
    assign c5 = '{a: 1'b1, b: 4'd2, c: 8'd4};
  end
  assign o5 = g5[0].c5;

  // c6 -- keyed pattern that is ONLY a default
  for (genvar i = 0; i < 1; i++) begin : g6
    s_t c6;
    assign c6 = '{default: '0};
  end
  assign o6 = g6[0].c6;

  // c7 -- member key MIXED with a default
  for (genvar i = 0; i < 1; i++) begin : g7
    s_t c7;
    assign c7 = '{a: 1'b1, default: '0};
  end
  assign o7 = g7[0].c7;

  // c8 -- NESTED keyed pattern under a keyed member
  for (genvar i = 0; i < 1; i++) begin : g8
    n_t c8;
    assign c8 = '{x: 2'd1, y: '{a: 1'b0, b: 4'd2, c: 8'd9}};
  end
  assign o8 = g8[0].c8;

  // c9 -- member value is a concat / replication expression
  for (genvar i = 0; i < 1; i++) begin : g9
    s_t c9;
    assign c9 = '{a: 1'b1, b: {2{2'b01}}, c: {din[3:0], 4'hA}};
  end
  assign o9 = g9[0].c9;

  // c10 -- member value reads the GENVAR
  for (genvar i = 0; i < 2; i++) begin : g10
    s_t c10;
    assign c10 = '{a: 1'b1, b: 4'(i), c: 8'(i + 1)};
  end
  assign o10 = g10[1].c10;

  // c11 -- member value reads a GEN-LOCAL localparam
  for (genvar i = 0; i < 1; i++) begin : g11
    localparam int LP = 6;
    s_t c11;
    assign c11 = '{a: 1'b0, b: 4'(LP), c: 8'(LP)};
  end
  assign o11 = g11[0].c11;

  // c12 -- explicit `var`
  for (genvar i = 0; i < 1; i++) begin : g12
    var s_t c12;
    assign c12 = '{a: 1'b1, b: 4'd9, c: 8'd11};
  end
  assign o12 = g12[0].c12;

  // c13 -- the namesake at module scope is a PARAMETER (bindVariable ignores
  // parameters), so this must stay gen-local and TAGGED
  for (genvar i = 0; i < 1; i++) begin : g13
    s_t c13;
    assign c13 = '{a: 1'b1, b: 4'd4, c: 8'd8};
  end
  assign o13 = g13[0].c13;

  // c15 -- single-member packed struct
  for (genvar i = 0; i < 1; i++) begin : g15
    one_t c15;
    assign c15 = '{q: 4'd6};
  end
  assign o15 = g15[0].c15;

  // c16 -- member value is a FUNCTION CALL
  for (genvar i = 0; i < 1; i++) begin : g16
    s_t c16;
    assign c16 = '{a: 1'b0, b: 4'd3, c: vp121::f8(din)};
  end
  assign o16 = g16[0].c16;

  // c17 -- continuous assign carrying a DELAY
  for (genvar i = 0; i < 1; i++) begin : g17
    s_t c17;
    assign #1 c17 = '{a: 1'b1, b: 4'd1, c: 8'd2};
  end
  assign o17 = g17[0].c17;

  // c18 -- COMMA-LIST continuous assign, both targets gen-local
  for (genvar i = 0; i < 1; i++) begin : g18
    s_t c18a, c18b;
    assign c18a = '{a: 1'b1, b: 4'd2, c: 8'd3},
           c18b = '{a: 1'b0, b: 4'd4, c: 8'd5};
  end
  assign o18a = g18[0].c18a;
  assign o18b = g18[0].c18b;

  // c19 -- type from the PACKAGE, member values from a module-scope localparam
  for (genvar i = 0; i < 1; i++) begin : g19
    vp121::s_t c19;
    assign c19 = '{a: 1'b1, b: 4'(PK), c: 8'(PK)};
  end
  assign o19 = g19[0].c19;

  // c20 -- generate `if` nested inside a generate `for`
  for (genvar i = 0; i < 1; i++) begin : g20o
    if (M > 1) begin : g20i
      s_t c20;
      assign c20 = '{a: 1'b0, b: 4'd7, c: din};
    end
  end
  assign o20 = g20o[0].g20i.c20;
endmodule

// c21 -- the SAME construct under a module instantiated TWICE
module vinst121 (input logic [7:0] d, output logic [12:0] y);
  import vp121::*;
  for (genvar i = 0; i < 1; i++) begin : g21
    s_t c21;
    assign c21 = '{a: 1'b1, b: 4'd3, c: d};
  end
  assign y = g21[0].c21;
endmodule

module vtop121 (input logic [7:0] d, input logic s,
                output logic [12:0] ya, output logic [12:0] yb);
  vinst121 ua (.d(d), .y(ya));
  vinst121 ub (.d(d), .y(yb));
  wire [12:0] w1, w2, w3, w4, w5, w6, w7, w9, w10, w11, w12, w13, w16, w17,
              w18a, w18b, w19, w20;
  wire [14:0] w8;
  wire  [3:0] w15;
  vaxis121 #(.M(2)) uax (.din(d), .sel(s),
    .o1(w1), .o2(w2), .o3(w3), .o4(w4), .o5(w5), .o6(w6), .o7(w7), .o8(w8),
    .o9(w9), .o10(w10), .o11(w11), .o12(w12), .o13(w13), .o15(w15),
    .o16(w16), .o17(w17), .o18a(w18a), .o18b(w18b), .o19(w19), .o20(w20));
endmodule
