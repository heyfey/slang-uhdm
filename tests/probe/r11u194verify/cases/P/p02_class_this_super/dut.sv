// § memberSelParenIdxSpan184: parenthesized trailing member-select indices through this and super paths and a handle chain in class methods
package pk;
  typedef struct packed { logic [3:0] f; } s_t;
  class base;
    s_t bs;
  endclass
  class der extends base;
    s_t ds;
    base h;
    function logic get(int i);
      logic r;
      r = this.ds.f[(i)];
      r = r ^ super.bs.f[(i + 1)];
      r = r ^ h.bs.f[((i))];
      return r;
    endfunction
  endclass
endpackage
module top; endmodule
