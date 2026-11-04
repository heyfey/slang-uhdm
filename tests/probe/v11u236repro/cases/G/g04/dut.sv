// § hpMidSelBaseSelDotted236 — package-parameter indices on both selects, a net right side
package pk;
  localparam int N = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t [1:0] g; } h_t;
  typedef struct packed { f_t [1:0] fs; h_t [1:0] hs; } r_t;
endpackage
module top import pk::*; (input logic clk, input logic [1:0] v, output logic [1:0] o);
  r_t [1:0] rc;
  assign rc[N].fs[N].q = v;
  assign rc[N].fs[0] = '0;
  assign rc[N].hs = '0;
  assign rc[0] = '0;
  assign o = rc[N].fs[N].q;
endmodule
