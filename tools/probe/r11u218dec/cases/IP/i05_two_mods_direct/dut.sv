// § impPatCopyFirstListingUnparented215 — (r11u218 independent grid of r11u215's law) i05_two_mods_direct: two top modules each import the home package
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
module m1 import hp::*; (output logic [5:0] o);
  assign o = EA;
endmodule
module m2 import hp::*; (output logic [5:0] o);
  assign o = EB;
endmodule
