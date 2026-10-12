// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module mp_pos (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module top (output logic [3:0] o);
  bif #(.W(8)) u ();
  mp_pos a3 (u.mp, o[3]);
endmodule
