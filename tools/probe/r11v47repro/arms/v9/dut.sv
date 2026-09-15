typedef struct packed { logic [7:0] x; logic [3:0] y; } ov1_t;
typedef struct packed { logic [5:0] m; logic [5:0] n; } ov2_t;
module sub #(parameter type it_t = struct packed { logic [7:0] x; logic [3:0] y; })
  (output logic [11:0] o);
  localparam it_t I = 12'd7;
  assign o = I;
endmodule
module dut;
  logic [11:0] a, b, c;
  sub             u0 (.o(a));
  sub #(.it_t(ov1_t)) u1 (.o(b));
  sub #(.it_t(ov2_t)) u2 (.o(c));
endmodule
