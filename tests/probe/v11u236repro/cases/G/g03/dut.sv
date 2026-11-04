// § hpMidSelBaseSelDotted236 — three selected levels
package pk;
  localparam int N = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t [1:0] g; } h_t;
  typedef struct packed { f_t [1:0] fs; h_t [1:0] hs; } r_t;
endpackage
module top import pk::*; (input logic clk, input logic [1:0] v, output logic [1:0] o);
  r_t [1:0] rc;
  assign rc[1].hs[1].g[0].q = 2'b11;
  assign rc[1].hs[1].g[1] = '0;
  assign rc[1].hs[0] = '0;
  assign rc[1].fs = '0;
  assign rc[0] = '0;
  assign o = rc[1].hs[1].g[0].q;
endmodule
