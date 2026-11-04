// § hpMidSelBaseSelDotted236 — a loop-variable index in a procedural lvalue
package pk;
  localparam int N = 1;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t [1:0] g; } h_t;
  typedef struct packed { f_t [1:0] fs; h_t [1:0] hs; } r_t;
endpackage
module top import pk::*; (input logic clk, input logic [1:0] v, output logic [1:0] o);
  r_t [1:0] rc;
  always_comb begin
    rc = '0;
    for (int i = 0; i < 2; i++) rc[1].fs[i].q = v;
  end
  assign o = rc[1].fs[1].q;
endmodule
