// § hpVarSelColumnJoin220 § hpVarSelRangeIdxNamesByPath220 — a trailing var_select in a static class function and a nested class method of a package
package p;
  typedef struct packed { logic [3:0][7:0] v; } w_t;
  class outer_c;
    static function logic [1:0] sget(w_t rw, int idx, int i);
      return rw.v[idx][i +: 2];
    endfunction
    class inner_c;
      w_t q;
      function logic [3:0] iget(int idx);
        return q.v[idx][3:0];
      endfunction
    endclass
  endclass
endpackage
module top;
  import p::*;
endmodule
