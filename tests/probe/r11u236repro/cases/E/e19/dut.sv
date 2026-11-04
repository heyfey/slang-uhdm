// § hpMidSelBaseSelDotted236 — a continuous-assignment lvalue member-array select followed by a member: plain base and selected base
package pk;
  localparam int N = 2;
  typedef struct packed { logic [1:0] q; } f_t;
  typedef struct packed { f_t [N:0] fs; } r_t;
endpackage
module top import pk::*; (output logic o);
  r_t t;
  r_t [1:0] rc;
  assign t.fs[1].q = 2'b10;
  assign rc[1].fs[0].q = 2'b01;
  assign t.fs[0] = '0;
  assign t.fs[2] = '0;
  assign rc[0] = '0;
  assign rc[1].fs[1] = '0;
  assign rc[1].fs[2] = '0;
  assign o = t.fs[1].q[1] ^ rc[1].fs[0].q[0];
endmodule
