// § udpPosModportPathAtSel305
interface bif;
  logic [3:0] d;
  modport mo (output d);
endinterface
module drv (bif.mo q, input logic i); assign q.d = {4{i}}; endmodule
module top (input logic i);
  bif u ();
  drv x (u.mo, i);
endmodule
