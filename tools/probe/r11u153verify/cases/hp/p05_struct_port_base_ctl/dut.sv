// § constPathBaseAnyKind146
typedef struct packed { logic [3:0] f; logic g; } s_t;
module m(input s_t cfg, output logic [$bits(cfg.f)-1:0] o);
  assign o = cfg.f;
endmodule
module top(input s_t i, output logic [3:0] o);
  m u(.cfg(i), .o(o));
endmodule
