// § impPatCopyFirstListingUnparented215 — $bits(EA) and an override of a child's parameter by EA, depth 2
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module sub #(parameter logic [5:0] X = 0) (output logic [5:0] o);
  assign o = X;
endmodule
module dut import ip::*; import hp::*; (output logic [5:0] o, output int w);
  assign w = $bits(EA);
  sub #(.X(EA)) u(.o(o));
endmodule
