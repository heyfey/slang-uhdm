// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
program pg (bif.mp q, output logic o);
  assign o = q.d[0];
endprogram
module top (output logic [3:0] o);
  bif u ();
  pg p (u.mp, o[1]);
endmodule
