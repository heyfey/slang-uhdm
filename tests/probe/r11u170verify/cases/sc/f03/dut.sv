// § sizeCastCaLitMask158
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module dut (output s_t s, output logic [3:0] p, output logic [3:0] q);
  assign s.a = 2'(7);
  assign s.b = 3'(13);
  assign {p, q} = 3'(-1);
endmodule
