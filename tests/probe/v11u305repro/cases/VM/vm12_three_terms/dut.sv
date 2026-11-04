// § udpPosModportPathAtSel305
interface bif;
  logic [3:0] d;
  modport mp (input d);
endinterface
module m3 (bif.mp q, bif.mp r, output logic o); assign o = q.d[0] ^ r.d[1]; endmodule
module top (output logic o);
  bif u ();
  bif v ();
  m3 x (u.mp, v.mp, o);
endmodule
