// § hpMidSelBaseSelDotted236 — a procedural lvalue
package pk;
  localparam int N = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t [1:0] g; } h_t;
  typedef struct packed { f_t [1:0] fs; h_t [1:0] hs; } r_t;
endpackage
module top import pk::*; (input logic clk, input logic [1:0] v, output logic [1:0] o);
  r_t [1:0] rc;
  always_ff @(posedge clk) rc[1].fs[0].q <= v;
  assign o = rc[1].fs[0].q;
endmodule
