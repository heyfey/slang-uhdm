// § genConnTrailSelChain205 — r11u217 g02: a local packed array of structs (element member bit-select `pa[1].en[k]`), a local struct variable `lv.en[k]`, and a parameter-expression index `cfg.en[P-1-k]`
typedef struct packed { logic [3:0] en; logic v; } cfg_t;
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module top #(parameter int P = 4) (input cfg_t cfg, input cfg_t [1:0] pin, output logic [3:0] o, output logic [3:0] p, output logic [3:0] r);
  cfg_t [1:0] pa;
  cfg_t lv;
  assign pa = pin;
  assign lv = cfg;
  for (genvar k = 0; k < 4; k++) begin : gen_l
    leaf u (.x(pa[1].en[k]), .y(o[k]));
    leaf w (.x(lv.en[k]), .y(p[k]));
    leaf z (.x(cfg.en[P-1-k]), .y(r[k]));
  end
endmodule
