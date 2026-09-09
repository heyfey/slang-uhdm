// r10v225 arm v8_scopedidx — NAMED associative indices the implementer's grid
// did not spell: a class-scope typedef, a PARAMETERIZED class scope and a type
// parameter.  All must take the SIZE model (`compileRanges` compiles a name
// bracket as an expression) and none may take the associative MARKER.
class Cs225 #(int W = 4);
  typedef int idx_t;
  int q;
endclass

package p225vs;
  typedef int pidx_t;
endpackage

interface if225v_si #(parameter type TP = int) ();
  typedef logic [7:0] tvs_t;
  typedef bit [3:0] loc_t;
  tvs_t s_loc   [loc_t];
  tvs_t s_pkg   [p225vs::pidx_t];
  tvs_t s_cls   [Cs225#(2)::idx_t];
  tvs_t s_tp    [TP];
  tvs_t s_hnd   [Cs225#(2)];
endinterface

module top225v_si(); endmodule
