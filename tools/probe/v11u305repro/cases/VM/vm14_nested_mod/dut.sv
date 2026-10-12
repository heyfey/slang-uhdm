// § udpPosModportPathAtSel305
interface bif;
  logic [3:0] d;
  modport mp (input d);
endinterface
module mp_pos (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module mid (output logic o);
  bif u ();
  mp_pos a (u.mp, o);
endmodule
module top (output logic [1:0] o);
  mid m0 (o[0]);
  mid m1 (o[1]);
endmodule
