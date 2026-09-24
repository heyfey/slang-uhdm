// § castTsPushLaidOut131
// case c03_macro_before
`define K 2
module top(input logic [15:0] a, output logic [5:0] o);
  assign o = `K + 6'(a) + int'(a[1:0]);
endmodule
