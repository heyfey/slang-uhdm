// § castTsPushLaidOut131
`define ID(x) x
module top (input logic [7:0] a, output logic [5:0] o);
  assign o = `ID(6'(a));
endmodule
