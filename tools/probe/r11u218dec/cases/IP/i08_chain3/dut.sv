// § impPatCopyFirstListingUnparented215 — (r11u218 independent grid of r11u215's law) i08_chain3: three packages: jp imports ip imports hp; the module imports jp
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
package jp;
  import ip::*;
  parameter logic [2:0] JL = 3'b101;
endpackage
module dut import jp::*; (output logic [2:0] o);
  assign o = JL;
endmodule
