// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module mp_pos2 (output logic o, bif.mp q); assign o = q.d[0]; endmodule
module top (output logic [3:0] o);
  bif u ();
  mp_pos2 a3 (o[3], u.mp);
endmodule
