// § defGenTargetIpsDefName205: a three-level path's indexed part select as a for-generate target
package p;
  typedef struct packed { logic [7:0] f; logic g; } s_t;
endpackage
interface bif;
  p::s_t s;
endinterface
module dut(input logic [3:0] x, output logic [8:0] o);
  bif b();
  for (genvar k = 0; k < 1; k++) begin : g
    assign b.s.f[4+:4] = x;
  end
  assign b.s.f[3:0] = '0;
  assign b.s.g = 1'b0;
  assign o = b.s;
endmodule
