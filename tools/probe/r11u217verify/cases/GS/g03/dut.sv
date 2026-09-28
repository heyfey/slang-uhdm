// § genConnTrailSelChain205 — r11u217 g03: a trailing INDEXED PART select `cfg.d[k*2 +: 2]` (the law reads bit-selects only) beside a bit-select in an if-generate inside a for-generate, and a case-generate
typedef struct packed { logic [7:0] d; logic [3:0] en; } cfg_t;
module leaf2 (input logic [1:0] x, output logic [1:0] y);
  assign y = x;
endmodule
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module top #(parameter int M = 1) (input cfg_t cfg, output logic [7:0] o, output logic [3:0] p, output logic q);
  for (genvar k = 0; k < 4; k++) begin : gl
    leaf2 u (.x(cfg.d[k*2 +: 2]), .y(o[k*2 +: 2]));
    if (k > 1) begin : gi
      leaf w (.x(cfg.en[k]), .y(p[k]));
    end else begin : ge
      assign p[k] = 1'b0;
    end
  end
  case (M)
    1: begin : gc
      leaf c (.x(cfg.en[3]), .y(q));
    end
    default: begin : gd
      assign q = 1'b0;
    end
  endcase
endmodule
