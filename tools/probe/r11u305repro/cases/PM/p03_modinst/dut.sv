// § udpPosModportPathAtSel305
interface bif #(parameter int W = 4);
  logic [W-1:0] d;
  modport mp (input d);
  modport mo (output d);
endinterface
module mp_in2 (input logic i, bif.mp q, output logic o); assign o = q.d[0] & i; endmodule
module top (output logic [3:0] o);
  bif u ();
  mp_in2 a3 (1'b1, u.mp, o[3]);
endmodule
