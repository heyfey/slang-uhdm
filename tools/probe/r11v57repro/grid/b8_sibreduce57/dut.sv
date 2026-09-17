// r11v57 B8 — R1's SEVERITY.  The surviving operation's OTHER operand is
// REDUCIBLE.  Golden's elaborated view substitutes it with its value; the
// emission re-renders the DEF-shaped syntax.  This arm scores whether the law
// is TOWARD or AWAY on the shape the implementer named as R1.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0], parameter int WID = 5)
            (output logic o);
  localparam int LOC = 6;
  localparam int R1 = WID + $bits(TP);            // sibling = PARAMETER PORT read
  localparam int R2 = LOC + $bits(TP);            // sibling = module localparam read
  localparam int R3 = (2 + 3) + $bits(TP);        // sibling = foldable literal op
  localparam int R4 = 1 + $bits(TP);              // sibling = plain literal (the witnesses')
  localparam logic [7:0] R5 = {{1'b1}, 7'($bits(TP))}; // sibling = a CONCAT
  localparam int R6 = (WID * 2) + $bits(TP);      // sibling = a foldable OPERATION over a param
  assign o = ^{R1[0], R2[0], R3[0], R4[0], R5[0], R6[0]};
endmodule
