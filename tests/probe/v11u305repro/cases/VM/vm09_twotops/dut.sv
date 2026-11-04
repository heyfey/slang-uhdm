// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module mp_pos (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module t1 (output logic o);
  bif u ();
  mp_pos a (u.mp, o);
endmodule
module t2 (output logic o);
  bif w ();
  mp_pos a (w.mp, o);
endmodule
