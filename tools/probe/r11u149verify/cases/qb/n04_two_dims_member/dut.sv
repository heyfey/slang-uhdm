// § pkgTsForeignQualRefUnstored144
package p;
  parameter int A = 2;
  parameter int B = 3;
endpackage
package q;
  typedef struct packed { logic [p::A-1:0][p::B-1:0] m; logic f; } s_t;
endpackage
module dut(input q::s_t s, output logic o);
  assign o = s.f;
endmodule
