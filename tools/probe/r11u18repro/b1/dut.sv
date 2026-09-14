// b1: PACKAGE holder.  Every member is written from a WHOLE READ OF A FORMAL;
// the actuals span the argument shapes and the formals span the typespec kinds.
package pk;
  typedef struct packed {
    int unsigned a;   // formal `int unsigned`, actual an UNSIZED literal
    int          b;   // formal `int`,          actual a SIZED literal
    logic [7:0]  c;   // formal `logic [7:0]`,  actual a sized literal
    bit          d;   // formal `bit`,          actual 1'b1
    int unsigned e;   // formal `int unsigned`, actual a PARAMETER read
    int unsigned f;   // formal `int unsigned`, actual an EXPRESSION
  } cfg_t;
  localparam int unsigned PK = 7;
  function automatic cfg_t mk(int unsigned xa, int xb, logic [7:0] xc, bit xd,
                              int unsigned xe, int unsigned xf);
    cfg_t c;
    c.a = xa; c.b = xb; c.c = xc; c.d = xd; c.e = xe; c.f = xf;
    return c;
  endfunction
  localparam cfg_t CFG = mk(64, 32'd5, 8'hAB, 1'b1, PK, PK + 1);
endpackage
module dut(output logic o);
  assign o = ^{pk::CFG.a[0], pk::CFG.b[0], pk::CFG.c[0], pk::CFG.d,
               pk::CFG.e[0], pk::CFG.f[0]};
endmodule
