// § pkgTsForeignQualRefUnstored144
package p;
  parameter int W = 4;
endpackage
package q;
  class c;
    logic [p::W-1:0] m;
  endclass
  typedef struct packed { logic [p::W-1:0] f; } s_t;
endpackage
module dut(input q::s_t s, output logic [3:0] o);
  assign o = s.f;
endmodule
