// t5: the corpus shape of param_nested_struct_field_width, trimmed: a
// localparam type whose default range bound reads a localparam int that
// comes from a nested field of a struct parameter.
package pk;
  typedef struct packed { int unsigned sidWidth; int unsigned dataWidth; } user_cfg_t;
  typedef struct packed { user_cfg_t u; int unsigned derived; } cfg_t;
  function automatic user_cfg_t mku();
    user_cfg_t c; c.sidWidth = 3; c.dataWidth = 32; return c;
  endfunction
  function automatic cfg_t build(user_cfg_t uu);
    cfg_t c; c.u = uu; c.derived = uu.dataWidth * 2; return c;
  endfunction
  localparam user_cfg_t UCFG = mku();
  localparam cfg_t      CFG  = build(UCFG);
endpackage
module dut #(
    parameter  pk::cfg_t CFG    = pk::CFG,
    localparam int       SID_W  = CFG.u.sidWidth,
    localparam int       NLOG   = $clog2(CFG.u.dataWidth / CFG.u.sidWidth),
    localparam type      sel_t  = logic [NLOG-1:0],
    localparam type      sid_t  = logic [SID_W-1:0]
) (input sel_t s, input sid_t d, output logic o);
  assign o = ^{s,d};
endmodule
