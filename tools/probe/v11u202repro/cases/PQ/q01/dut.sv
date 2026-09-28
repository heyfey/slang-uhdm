// § posOpConnKeepsRefModule200
module sub (input logic [6:0] a, input logic [6:0] b, output logic [6:0] o);
  assign o = a ^ b;
endmodule
module q01 (input logic [6:0] r, input logic [6:0] s, output logic [6:0] o1, output logic [6:0] o2, output logic [6:0] o3, output logic [6:0] o4);
  sub u1 ({r[3:0], s[2:0]}, r + s, o1);
  sub u2 (r[6:0], ~s, o2);
  sub u3 ((r), s & r, o3);
  sub u4 (r ? s : r, s, o4);
endmodule
