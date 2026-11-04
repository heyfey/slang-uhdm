// § topNestedArrElemTopTwin269
package p;
  typedef struct packed {
    struct packed { logic q; } en;
    logic [3:0] base;
  } mreg_t;
  typedef struct packed {
    struct packed { logic q; } top_en;
    mreg_t [1:0] cfg;
  } reg2hw_t;
  function automatic logic first_en(reg2hw_t r);
    return r.cfg[0].en.q;
  endfunction
endpackage
module top(input p::reg2hw_t r, output logic o);
  assign o = p::first_en(r);
endmodule
