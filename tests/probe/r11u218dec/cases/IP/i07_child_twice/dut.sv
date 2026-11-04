// § impPatCopyFirstListingUnparented215 — (r11u218 independent grid of r11u215's law) i07_child_twice: a top instantiates twice a child that imports the importing package
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module c import ip::*; (output logic [1:0] o);
  assign o = LOC;
endmodule
module dut (output logic [1:0] o1, o2);
  c u1(.o(o1));
  c u2(.o(o2));
endmodule
