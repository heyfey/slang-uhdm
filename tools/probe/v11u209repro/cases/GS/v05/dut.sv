// § genConnTrailSelChain205: a generate-scope interface instance whose port reads a member bit select
package rp;
  typedef struct packed { logic [3:0] a; logic b; } r_t;
endpackage
interface cif (input logic clk);
  logic q;
  assign q = clk;
endinterface
module top(input rp::r_t w, output logic [3:0] o);
  for (genvar k = 0; k < 4; k++) begin : g
    cif c (.clk(w.a[k]));
    assign o[k] = c.q;
  end
endmodule
