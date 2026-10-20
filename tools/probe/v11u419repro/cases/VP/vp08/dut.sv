// § implicitPortPaLastIface419
package pk;
  typedef struct packed { int unsigned w; int unsigned d; } cfg_t;
  localparam cfg_t DEF = '{w: 8, d: 4};
  parameter Q = 3;
  function automatic int get_w(cfg_t c); return c.w; endfunction
endpackage
interface ifc
  import pk::*;
#(
  cfg_t CFG = DEF
);
  typedef logic [get_w(CFG)-1:0] word_t;
  localparam int L = CFG.d * Q;
  word_t x;
endinterface
module top;
  ifc #(.CFG('{w: 4, d: 2})) u();
  ifc v();
endmodule
