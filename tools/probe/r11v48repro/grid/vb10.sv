// vb10 — a signed/unsigned bound on a PACKED STRUCT member.
module vb10 (input logic c, output logic o);
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
  typedef struct packed { logic [PS:0] a; logic [PU:0] b; } t_t;
  t_t s;
  assign o = c ^ s.a[0] ^ s.b[0];
endmodule
