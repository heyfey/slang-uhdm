// § elabCaConstLhsSized191: unsized package parameters into a part-select target, a signed target and a concatenation target, qualified and imported
package p;
  parameter V = 'o777;
  parameter D = 300;
endpackage
module m(output logic [9:0] y, output logic signed [9:0] s, output logic [3:0] a, output logic [3:0] b);
  import p::V;
  assign y[5:2] = V;
  assign s = p::D;
  assign {a, b} = V;
endmodule
module top(output logic [9:0] y1, y2, output logic signed [9:0] s1, s2, output logic [3:0] a1, b1, a2, b2);
  m u1(.y(y1), .s(s1), .a(a1), .b(b1));
  m u2(.y(y2), .s(s2), .a(a2), .b(b2));
endmodule
