// § ppMacroBodyLines160 § hpSelRoute157
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
typedef struct packed { int W; int D; } cfg_t;
`define PICK(o, s, v) \
  always_comb begin \
    o = v[s.a +: 4] ^ \
        v[Cfg.D-1:0]; \
    o[s.b[1:0]] = 1'b0; \
  end
module top #(parameter cfg_t Cfg = '{W: 8, D: 4}) (input s_t s, input logic [15:0] v, output logic [3:0] q);
  `PICK(q, s, v)
endmodule
