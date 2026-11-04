// § udpPosModportPathAtSel305
interface bif;
  logic [3:0] d;
  modport mp (input d);
endinterface
module cm (bif.mp q, input logic e, output logic o); assign o = q.d[0] & e; endmodule
module top (output logic o);
  bif u ();
  cm c (u.mp, 1'b1, o);
endmodule
