package yp121;
  typedef enum logic [2:0] { YA = 3'h1, YB = 3'h5 } ye_t;
  typedef struct packed { logic a; ye_t op; logic [7:0] d; } y_t;
  typedef y_t y2_t;          // typedef CHAIN
  typedef struct packed { logic [1:0] hi; y_t lo; } yn_t;
endpackage

module vmore121 #(parameter int W = 1) (input logic [7:0] din,
  output logic [11:0] r1, output logic [11:0] r2, output logic [11:0] r3,
  output logic [11:0] r4, output logic [13:0] r5, output logic [11:0] r6);
  // m1 -- typedef CHAIN target
  for (genvar i = 0; i < 1; i++) begin : m1
    yp121::y2_t v;
    assign v = '{a: 1'b1, op: yp121::YA, d: din};
  end
  assign r1 = m1[0].v;

  // m2 -- target DECLARED AFTER the assign in the same block
  for (genvar i = 0; i < 1; i++) begin : m2
    yp121::y_t v;
    assign v = '{a: 1'b0, op: yp121::YB, d: din};
  end
  assign r2 = m2[0].v;

  // m3 -- the pattern reads the target's OWN member (combinational loop)
  for (genvar i = 0; i < 1; i++) begin : m3
    yp121::y_t v;
    assign v = '{a: v.d[0], op: yp121::YA, d: din};
  end
  assign r3 = m3[0].v;

  // m4 -- `default:` whose value is itself an expression, member key after it
  for (genvar i = 0; i < 1; i++) begin : m4
    yp121::y_t v;
    assign v = '{a: 1'b1, op: yp121::YA, default: 8'd0};
  end
  assign r4 = m4[0].v;

  // m5 -- NESTED struct target, nested keyed pattern under the member key
  for (genvar i = 0; i < 1; i++) begin : m5
    yp121::yn_t v;
    assign v = '{hi: 2'd2, lo: '{a: 1'b1, op: yp121::YB, d: din}};
  end
  assign r5 = m5[0].v;

  // m6 -- inside a generate block of a PARAMETERISED instance
  for (genvar i = 0; i < W; i++) begin : m6
    yp121::y_t v;
    assign v = '{a: 1'b1, op: yp121::YA, d: 8'(i) + din};
  end
  assign r6 = m6[0].v;
endmodule

module vmoretop121 (input logic [7:0] din, output logic [11:0] q1, output logic [11:0] q2);
  wire [11:0] a1,a2,a3,a4,a6, b1,b2,b3,b4,b6; wire [13:0] a5,b5;
  vmore121 #(.W(1)) ia (.din(din), .r1(a1), .r2(a2), .r3(a3), .r4(a4), .r5(a5), .r6(a6));
  vmore121 #(.W(2)) ib (.din(din), .r1(b1), .r2(b2), .r3(b3), .r4(b4), .r5(b5), .r6(b6));
  assign q1 = a1 ^ a2 ^ a3 ^ a4 ^ a5[11:0] ^ a6;
  assign q2 = b1 ^ b2 ^ b3 ^ b4 ^ b5[11:0] ^ b6;
endmodule
