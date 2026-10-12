// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module only_mp (bif.mp q); logic z; assign z = q.d[0]; endmodule
module top (output logic [3:0] o);
  bif u ();
  only_mp a3 (u.mp);
endmodule
