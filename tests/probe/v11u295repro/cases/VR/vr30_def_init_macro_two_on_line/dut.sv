// § rawEndLineModel295
`define V 8'h3
module top(output logic [7:0] o);
  logic [7:0] a = `V, b = `V;
  assign o = a ^ b;
endmodule
