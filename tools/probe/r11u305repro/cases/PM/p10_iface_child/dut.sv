// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
interface wrap (bif.mp q);
  logic z;
  assign z = q.d[0];
endinterface
module top (output logic [3:0] o);
  bif u ();
  wrap w (u.mp);
  assign o[0] = w.z;
endmodule
