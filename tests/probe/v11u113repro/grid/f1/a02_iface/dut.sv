package pk; parameter int unsigned P = 5; endpackage
interface ifc import pk::*; ();
  logic [P:0] x;
endinterface
module top (input logic [7:0] i, output logic [7:0] o);
  ifc u();
  assign u.x = i[5:0];
  assign o = u.x;
endmodule
