// § impPatCopyFirstListingUnparented215 — (r11u218 independent grid of r11u215's law) i12_mixed_concat: the importing package's own concatenation parameter beside hp's pattern
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [7:0] CAT = { 4'h?, 4'b0101 };
endpackage
module dut import ip::*; (output logic [7:0] o);
  assign o = CAT;
endmodule
