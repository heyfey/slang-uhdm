// t5: the TEST's own shape -- a localparam type whose default reads a
// localparam int computed from a nested field of a struct parameter.
package pk;
  typedef struct packed { int unsigned w; } cfg_t;
  function automatic cfg_t mk(); cfg_t c; c.w = 4; return c; endfunction
  localparam cfg_t CFG = mk();
endpackage
module dut #(
    parameter  pk::cfg_t CFG   = pk::CFG,
    localparam int       W     = CFG.w,
    localparam type      sel_t = logic [W-1:0],
    parameter  type      par_t = logic [W-1:0]
) (input sel_t s, input par_t p, output logic o);
  assign o = ^{s,p};
endmodule
