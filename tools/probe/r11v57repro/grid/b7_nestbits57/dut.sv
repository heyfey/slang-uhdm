// r11v57 B7 — the call is inside the DATA TYPE argument of ANOTHER $bits, and
// inside a type's range.  The visitor does not descend into a DataTypeExpression's
// type, so the outer node is the only one the gate can see.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  localparam int N1 = $bits(logic [$bits(TP)-1:0]);   // call inside the TYPE arg
  localparam int N2 = $bits(logic [3:0]);             // CONTROL
  typedef logic [$bits(TP)-1:0] loc_t;                // call inside a typedef range
  localparam int N3 = (1 << $bits(loc_t));            // $bits of THAT typedef
  assign o = ^{N1[0], N2[0], N3[0]};
endmodule
