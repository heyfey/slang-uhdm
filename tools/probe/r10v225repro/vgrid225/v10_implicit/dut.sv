// r10v225 arm v10_implicit — REAL NETS (not variables) with unpacked
// dimensions, every net keyword, plus a param-sized dim and a `[N-1:0]` range,
// in an interface that IS instantiated (so the def and elab views are both
// scored).  MEASURED: a net of a QUEUE or ASSOCIATIVE type is illegal SV
// ("only 4-state integral types and unpacked structs/unions and arrays of such
// types"), so a NET can only ever carry FIXED or DYNAMIC unpacked levels.
interface if225v_net();
  parameter int WN = 4;
  typedef logic [7:0] tvw_t;
  wire         w_plain [1:0];
  wire  [1:0]  w_pk    [1:0];
  wire  logic  w_lg    [1:0];
  wand         w_and   [1:0];
  wor          w_or    [1:0];
  tri          w_tri   [1:0];
  wire  tvw_t  w_td    [1:0];
  wire         w_par   [WN];
  wire         w_rng   [WN-1:0];
  logic        v_par   [WN];
  logic        v_dyn   [];
endinterface

module top225v_net();
  if225v_net u_n();
endmodule
