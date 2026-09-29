// § impPatCopyFirstListingUnparented215 — (r11u218 independent grid of r11u215's law) i06_two_mods_via_ip: two top modules each import the importing package
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module m1 import ip::*; (output logic [1:0] o);
  assign o = LOC;
endmodule
module m2 import ip::*; (output logic [1:0] o);
  assign o = LOC;
endmodule
