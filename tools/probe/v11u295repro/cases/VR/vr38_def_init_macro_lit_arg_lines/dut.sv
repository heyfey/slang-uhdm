// § rawEndLineModel295
`define LIT(x) x
module top(output logic [7:0] o);
  logic [7:0] a = `LIT(
     8'h3);
  assign o = a;
endmodule
