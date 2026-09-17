// r11v57 B2 — an EXPLICIT CAST at the root of the initializer.  `elabCondBranch57`
// strips only IMPLICIT conversions, so the emission starts at the cast node.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  localparam int C1 = int'($bits(TP) + 1);       // explicit type cast at root
  localparam int C2 = int'($bits(pk::req_t) + 1);// CONTROL
  localparam logic [7:0] C3 = 8'($bits(TP));     // SIZED cast at root
  localparam int C4 = signed'($bits(TP) + 1);    // sign cast at root
  localparam int C5 = int'($bits(TP));           // cast over the WHOLE-Rhs shape
  assign o = ^{C1[0], C2[0], C3[0], C4[0], C5[0]};
endmodule
