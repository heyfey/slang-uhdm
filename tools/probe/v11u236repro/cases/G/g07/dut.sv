// § hpMidSelBaseSelDotted236 — a net base
package pk;
  localparam int N = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t [1:0] g; } h_t;
  typedef struct packed { f_t [1:0] fs; h_t [1:0] hs; } r_t;
endpackage
module top import pk::*; (input logic clk, input logic [1:0] v, output logic [1:0] o);
  r_t [1:0] rc;
  wire r_t [1:0] rn;
  assign rn[1].fs[0].q = v;
  assign rn[1].fs[1] = '0;
  assign rn[1].hs = '0;
  assign rn[0] = '0;
  assign o = rn[1].fs[0].q;
endmodule
