// § castTsPushLaidOut131
`define W 6
module top (input logic [7:0] a, output logic [5:0] o, output logic [5:0] p);
  assign o = `W'(a); assign p = 6'(a);
endmodule
