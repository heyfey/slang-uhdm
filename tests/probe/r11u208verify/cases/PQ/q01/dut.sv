// § posOpConnKeepsRefModule200
module sub (input [3:0] d, input [3:0] e, output logic [3:0] o);
  assign o = d ^ e;
endmodule
module q01 (input logic [7:0] i, output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3, output logic [3:0] o4);
  logic [7:0] r;
  assign r = i;
  sub u1 (r[3:0], r[7:4], o1);
  sub u2 ({r[1:0], r[3:2]}, r[3:0], o2);
  sub u3 (~r[3:0], r[3:0], o3);
  sub u4 (r[0] ? r[3:0] : r[7:4], 4'd1, o4);
endmodule
