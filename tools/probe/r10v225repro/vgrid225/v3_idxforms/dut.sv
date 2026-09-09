// r10v225 arm v3_idxforms — R-A's BOUNDARY, widened past the implementer's
// fourteen: every remaining built-in associative index keyword, plus the
// anonymous (unnamed) aggregate index forms `assocIdxIsBuiltin225` sends to
// `default:`.
typedef logic [7:0] tvi_t;

interface if225v_idx();
  tvi_t i_longint  [longint];
  tvi_t i_time     [time];
  tvi_t i_iuns     [int unsigned];
  tvi_t i_buns     [byte unsigned];
  tvi_t i_reg      [reg];
  tvi_t i_lint     [longint unsigned];
  tvi_t i_pk2      [logic [1:0]];
  tvi_t i_wild     [*];
  tvi_t i_string   [string];
endinterface

module top225v_idx(); endmodule
