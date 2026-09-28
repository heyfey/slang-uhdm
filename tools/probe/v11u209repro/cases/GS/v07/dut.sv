// § genConnTrailSelChain205: a register-file shape, genvar-indexed member of a module input struct, clocked child
package rp;
  typedef struct packed { logic [7:0] en; logic [7:0] q; } r_t;
endpackage
module acc(input logic clk, input logic en_i, input logic d, output logic q);
  always_ff @(posedge clk) if (en_i) q <= d;
endmodule
module top(input logic clk, input rp::r_t w, output logic [7:0] o);
  for (genvar k = 0; k < 8; k++) begin : gen_classes
    acc i_accu(.clk(clk), .en_i(w.en[k]), .d(w.q[k]), .q(o[k]));
  end
endmodule
