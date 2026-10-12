// § udpPosModportPathAtSel305
interface bif;
  logic [3:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module two (bif.mp q, bif.mo r, output logic o); assign o = q.d[0]; assign r.d = 4'h1; endmodule
module top (output logic o);
  bif u ();
  bif v ();
  two t (u.mp, v.mo, o);
endmodule
