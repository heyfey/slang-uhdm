// r11v57 B3 — a ZERO REPLICATION and other operand-discarding shapes: does the
// producer's reduce drop an operand the way a not-taken branch is dropped?
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  localparam logic [7:0] Z1 = {{0{$bits(TP)}}, 8'd1};  // zero replication of the call
  localparam int         Z2 = 0 * $bits(TP);           // multiply by zero
  localparam int         Z3 = $bits(TP) - $bits(TP);   // self-cancelling
  localparam logic       Z4 = (1'b1) || ($bits(TP) > 0); // short circuit, TRUE side
  localparam logic [7:0] Z5 = {8{1'b1}} & {8{1'b0}};   // CONTROL: no call at all
  assign o = ^{Z1[0], Z2[0], Z3[0], Z4, Z5[0]};
endmodule
