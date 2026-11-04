// § elabImpSelFlatKeepsParent302
// vg02: two modules, one wildcard importing and one explicitly importing the selected pattern, plus one reading it
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5};
  typedef logic [WSEL.a-1:0] w1_t;
endpackage
module q1 import p7::*; (output logic [3:0] o);
  w1_t d;
  assign d = '0;
  assign o = d[3:0];
endmodule
module q2 (output logic [31:0] o);
  import p7::WSEL;
  assign o = WSEL.b;
endmodule
module dut(output logic [3:0] o1, output logic [31:0] o2);
  q1 u1 (.o(o1));
  q2 u2 (.o(o2));
endmodule
