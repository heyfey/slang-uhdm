// § memLeftSliceUnlocated169
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = x;
    c.B = x / 8;
    c.C = 7;
    return c;
  endfunction
endpackage
module top (output logic [3:0] o);
  localparam p::cfg_t Cfg = p::mk(64, 5);
  assign o = Cfg.B[3:0];
endmodule
