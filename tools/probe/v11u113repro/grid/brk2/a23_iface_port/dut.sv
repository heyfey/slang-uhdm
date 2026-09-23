package pk; parameter int unsigned P = 5; endpackage
interface ifc import pk::*; (input logic [P:0] d);
  logic [P:0] x;
  assign x = d;
endinterface
module top (input logic [7:0] i, output logic [7:0] o);
  ifc u(.d(i[5:0]));
  assign o = u.x;
endmodule
