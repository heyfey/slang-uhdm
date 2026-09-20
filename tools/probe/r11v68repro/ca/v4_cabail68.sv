// v11u68 ADVERSARIAL arm v4 — DOES THE BAIL REACH THE cont_assign SITE TOO?
// LAW B stamps the member width on EVERY operand it reaches.  But the
// cont_assign Rhs is re-materialised by the SAME `expandPatternAssignment`
// (writeCont -> flattenPatternAssignments -> expandPatternAssignment), so the
// SAME `if (invalidValue) return result;` must stop the stamp there as well.
// X1 has a bail (`-3`) BEFORE the tail members; X2 is the identical struct
// with the bail moved to the END.  If the bail reaches this site, golden's
// tail cells read the LITERAL width in X1 and the MEMBER width in X2.
package pw;
  localparam UD16 = 16'd4660;
  typedef struct packed {
    logic [7:0] a;      // 16'd4660 -- before any bail
    logic signed [7:0] bail;  // -3  (INT:-3, get_uvalue refuses)
    logic [7:0] c;      // 16'd4660 -- AFTER the bail
    logic [7:0] d;      // UD16 (a NAME) -- AFTER the bail
    logic [23:0] e;     // 16'd4660 on a WIDER member -- AFTER the bail
  } x_t;
  typedef struct packed {
    logic [7:0] a;
    logic [7:0] c;
    logic [7:0] d;
    logic [23:0] e;
    logic signed [7:0] bail;  // the bail LAST
  } y_t;
  localparam x_t X1 = '{a: 16'd4660, bail: -3, c: 16'd4660, d: UD16, e: 16'd4660};
  localparam y_t X2 = '{a: 16'd4660, c: 16'd4660, d: UD16, e: 16'd4660, bail: -3};
endpackage
module xm #(parameter pw::x_t C = pw::X1)
  (output logic [31:0] q1, output logic [31:0] q2, output logic [31:0] q3,
   output logic [31:0] q4, output logic [31:0] q5);
  assign q1 = C.a; assign q2 = C.bail; assign q3 = C.c; assign q4 = C.d; assign q5 = C.e;
endmodule
module ym #(parameter pw::y_t C = pw::X2)
  (output logic [31:0] r1, output logic [31:0] r2, output logic [31:0] r3,
   output logic [31:0] r4, output logic [31:0] r5);
  assign r1 = C.a; assign r2 = C.c; assign r3 = C.d; assign r4 = C.e; assign r5 = C.bail;
endmodule
module v4_cabail68
  (output logic [31:0] x1,x2,x3,x4,x5, output logic [31:0] y1,y2,y3,y4,y5);
  xm u_x (.q1(x1),.q2(x2),.q3(x3),.q4(x4),.q5(x5));
  ym u_y (.r1(y1),.r2(y2),.r3(y3),.r4(y4),.r5(y5));
endmodule
