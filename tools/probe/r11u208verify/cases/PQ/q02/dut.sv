// § posOpConnKeepsRefModule200
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module sub (input [3:0] d, output logic [3:0] o);
  assign o = ~d;
endmodule
module q02 (input s_t s, output logic [3:0] o1, output logic [3:0] o2);
  sub u1 (s.a, o1);
  sub u2 (s.b + 4'd1, o2);
endmodule
