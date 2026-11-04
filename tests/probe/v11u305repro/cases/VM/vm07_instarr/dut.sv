// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module mp_pos (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module top (output logic [1:0] o);
  bif u ();
  mp_pos a [1:0] (u.mp, o);
endmodule
