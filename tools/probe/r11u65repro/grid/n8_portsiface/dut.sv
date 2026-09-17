// r11u65 n8 — the two cells n3/n5 did not spell: an ANSI PORT declared with an
// unpacked-array typedef, and an INTERFACE net whose unpacked dimension is
// WRITTEN ON THE DECLARATOR (the shape that also mints an array_net, §
// ifaceDefArrayNetIsAnyUnpackedDim225), plus a MODPORT view of both.
interface ifc8 #(parameter int unsigned N = 2, parameter int unsigned D = 4) ();
  typedef logic [N-1:0] a_t [D];
  typedef logic [N-1:0] v_t;
  a_t ta;            // typedef-carried dim
  v_t vd [D];        // packed typedef + WRITTEN dim  -> array_net cell
  v_t vp;            // packed typedef, no dim
  modport mp (input ta, vd, vp);
endinterface

module sub8 #(parameter int unsigned N = 2, parameter int unsigned D = 4)
  (input logic [N-1:0] q [D], output logic [N-1:0] o);
  typedef logic [N-1:0] a_t [D];
  a_t sb;
  assign o = q[0] | sb[0];
endmodule

module dut (output logic [1:0] o);
  ifc8 u();
  logic [1:0] pq [4];
  logic [1:0] so;
  sub8 s1 (.q(pq), .o(so));
  assign o = u.ta[0] | u.vd[0] | u.vp | so;
endmodule
