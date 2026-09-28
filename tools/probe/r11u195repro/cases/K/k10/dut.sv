// § procNetMidSelDotted195 — grid K/k10 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
interface bus_if; rp::reg2hw_t r; modport mp(input r); endinterface
module sub(bus_if.mp b, output logic [31:0] a);
  always_comb a = b.r.key[1].q;
endmodule
module top(output logic [31:0] a);
  bus_if bi();
  sub u(.b(bi), .a(a));
endmodule
