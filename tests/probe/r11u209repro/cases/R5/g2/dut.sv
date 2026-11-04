// § genConnTrailSelChain205: an if-generate instance connected to a member select with a literal index
typedef struct packed { logic [3:0] en; logic v; } cfg_t;
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module top #(parameter bit P = 1) (input cfg_t cfg, output logic o);
  if (P) begin : gen_i
    leaf u (.x(cfg.en[2]), .y(o));
  end
endmodule
