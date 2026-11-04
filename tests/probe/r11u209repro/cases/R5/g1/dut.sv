// § genConnTrailSelChain205: a for-generate instance connected to a struct member array select
typedef struct packed { logic [3:0] en; logic v; } cfg_t;
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module top (input cfg_t cfg, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : gen_l
    leaf u (.x(cfg.en[k]), .y(o[k]));
  end
endmodule
