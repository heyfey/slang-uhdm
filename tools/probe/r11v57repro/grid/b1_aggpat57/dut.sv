// r11v57 B1 — AGGREGATE INITIALIZER holding a buried $bits(<type param>).
// The widened gate claims the WHOLE initializer and hands it to emitExpr.
// If golden folds an assignment pattern whose one element is a surviving
// call, the base (folded constant) was RIGHT and the law is AWAY.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  localparam logic [15:0] A1 [0:1] = '{$bits(TP), 16'd3};   // unpacked array pattern
  localparam logic [15:0] A2 [0:1] = '{16'd9, 16'd3};       // CONTROL: no call
  typedef struct packed { logic [15:0] x; logic [15:0] y; } pair_t;
  localparam pair_t A3 = '{x: $bits(TP), y: 16'd4};         // struct pattern
  localparam pair_t A4 = '{x: 16'd8,     y: 16'd4};         // CONTROL
  localparam logic [31:0] A5 = {16'($bits(TP)), 16'd7};     // CONCAT, sized cast
  assign o = ^{A1[0][0], A2[0][0], A3.x[0], A4.x[0], A5[0]};
endmodule
