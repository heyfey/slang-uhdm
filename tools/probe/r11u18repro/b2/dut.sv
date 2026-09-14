// b2: b1's MODULE-holder twin -- the same struct and the same function, with
// the assembled localparam held by the MODULE instead of the package.
package pk;
  typedef struct packed {
    int unsigned a;
    int          b;
    logic [7:0]  c;
    bit          d;
    int unsigned e;
    int unsigned f;
  } cfg_t;
  localparam int unsigned PK = 7;
  function automatic cfg_t mk(int unsigned xa, int xb, logic [7:0] xc, bit xd,
                              int unsigned xe, int unsigned xf);
    cfg_t c;
    c.a = xa; c.b = xb; c.c = xc; c.d = xd; c.e = xe; c.f = xf;
    return c;
  endfunction
endpackage
module dut(output logic o);
  localparam pk::cfg_t CFG = pk::mk(64, 32'd5, 8'hAB, 1'b1, pk::PK, pk::PK + 1);
  assign o = ^{CFG.a[0], CFG.b[0], CFG.c[0], CFG.d, CFG.e[0], CFG.f[0]};
endmodule
