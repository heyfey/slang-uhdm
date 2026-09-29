// § impPatCopyFirstListingUnparented215 — (r11u218 independent grid of r11u215's law) i04_direct: the module imports the home package only
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
module dut import hp::*; (output logic [5:0] o);
  assign o = EA;
endmodule
