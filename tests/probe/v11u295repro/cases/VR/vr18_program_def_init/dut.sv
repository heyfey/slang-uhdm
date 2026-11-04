// § rawEndLineModel295
`define V 8'h3
program prg(output logic [7:0] o);
  logic [7:0] a = `V;
  assign o = a;
endprogram
module top(output logic [7:0] o);
  prg p(.o(o));
endmodule
