// § rawEndLineModel295
module top(output logic [7:0] o);
  logic \x.a ; logic a = 1;
  logic \x.b ; bit b = 1;
  logic \x.c ; int c = 1;
  logic \x.d ; integer e = 1;
  logic \x.f ; logic signed [3:0] f = 1;
  logic \x.g ; reg g = 1;
  logic \x.h ; var h = 1;
  logic \x.i ; logic [1:0] i [2];
  logic \x.j ; var logic [1:0] j = 1;
  assign o = {a, b, c[0], e[0], f[0], g, h, i[0][0]};
endmodule
