// § udpPosModportPathAtSel305
interface bif;
  logic [3:0] d;
  modport mp (input d);
endinterface
module mp_pos #(parameter int K = 1) (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module top (output logic [1:0] o);
  bif u ();
  mp_pos #(4) a (u.mp, o[0]);
  mp_pos #(.K(4)) b (u.mp, o[1]);
endmodule
