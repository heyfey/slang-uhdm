// § elabCaConstLhsSized191: unsized based-decimal and hex package parameters narrowed and widened by two instances' left sides
package pk;
  parameter P = 'd300;
  parameter H = 'h1FF;
endpackage
module sub #(parameter int W = 8) (output logic [W-1:0] a, output logic [W-1:0] b);
  assign a = pk::P;
  assign b = pk::H;
endmodule
module top(output logic [3:0] a1, b1, output logic [15:0] a2, b2);
  sub #(4) u1 (a1, b1);
  sub #(16) u2 (a2, b2);
endmodule
