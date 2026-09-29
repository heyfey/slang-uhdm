// § impPatMemberReadKeepsParent215v — a local struct variable named EA read by member select elsewhere (the name-based scan declines)
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module other (output logic q);
  hp::e_t EA;
  assign EA = '0;
  assign q = EA.b;
endmodule
module dut import ip::*; (output logic [5:0] o, output logic q);
  assign o = LOC;
  other u(.q(q));
endmodule
