// § genConnTrailSelChain205 — r11u217 g04: generate-scope INTERFACE instances connected with a trailing member bit-select, and a module instance whose actual is an operation over two member bit-selects (not a hier_path)
typedef struct packed { logic [3:0] en; logic v; } cfg_t;
interface pi (input logic c);
  logic w;
  assign w = c;
endinterface
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module top (input cfg_t cfg, output logic [3:0] o, output logic [3:0] p);
  for (genvar k = 0; k < 4; k++) begin : gl
    pi ii (.c(cfg.en[k]));
    assign o[k] = ii.w;
    leaf u (.x(cfg.en[k] & cfg.v), .y(p[k]));
  end
endmodule
