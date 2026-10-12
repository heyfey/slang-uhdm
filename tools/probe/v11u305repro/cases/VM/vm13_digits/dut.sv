// § udpPosModportPathAtSel305
interface bif;
  logic [3:0] d;
  modport mp_0 (input d);
endinterface
module mp_pos (bif.mp_0 q, output logic o); assign o = q.d[0]; endmodule
module top (output logic o);
  bif u_0 ();
  mp_pos a_1 (u_0.mp_0, o);
endmodule
