// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module mo_pos (bif.mo q, input logic i); assign q.d[0] = i; endmodule
module top (input logic i);
  bif u ();
  mo_pos a3 (u.mo, i);
endmodule
