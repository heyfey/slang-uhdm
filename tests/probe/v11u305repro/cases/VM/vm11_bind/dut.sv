// § udpMpPathBindAbstains305v
interface bif;
  logic [3:0] d;
  modport mp (input d);
endinterface
module mp_pos (bif.mp q, output logic o); assign o = q.d[0]; endmodule
module top (output logic o);
  bif u ();
endmodule
bind top mp_pos a (u.mp, o);
