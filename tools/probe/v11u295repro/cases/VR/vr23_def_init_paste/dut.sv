// § rawEndLineModel295
`define CAT(x,y) x``y
module top(output logic [7:0] o);
  logic [7:0] ab = 8'h1;
  logic [7:0] x = `CAT(a,b);
  assign o = x;
endmodule
