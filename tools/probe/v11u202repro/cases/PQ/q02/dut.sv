// § posOpConnKeepsRefModule200
module sub (input logic [6:0] a, input logic [6:0] b, output logic [6:0] o);
  assign o = a ^ b;
endmodule
module q02 (input logic [6:0] r, input logic [6:0] s, output logic [6:0] o1, output logic [6:0] o2, output logic [6:0] o3);
  sub u1 (7'd3, r + s, o1);
  sub u2 ($unsigned(r), s, o2);
  sub u3 (r, , o3);
  sub u4 (, r, );
endmodule
