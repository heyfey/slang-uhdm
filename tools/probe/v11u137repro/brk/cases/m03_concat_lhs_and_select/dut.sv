// § caLhsDefNetUnlessOpRhs139
module sub(input logic [3:0] a, output logic [1:0] y, output logic [1:0] z, output logic [3:0] w);
  assign {y, z} = a;
  assign w[0] = a[0];
  assign w[3:1] = a[3:1] & 3'b101;
endmodule
module top(input logic [3:0] x, output logic [1:0] a, b, output logic [3:0] c);
  sub u(.a(x), .y(a), .z(b), .w(c));
endmodule
