// r10v77 -- ADVERSARIAL grid D: `ref` ports (the fourth direction) with a
// scoped package typedef, plus the same shape in a task/function boundary.
package d77;
  typedef logic [7:0] v8_t;
endpackage

module leafR (
  ref    d77::v8_t r_pv,
  ref    logic [7:0] r_lv,
  input  d77::v8_t i_pv,
  output d77::v8_t o_pv
);
  assign o_pv = i_pv;
endmodule

module topR;
  d77::v8_t rv;
  logic [7:0] lv;
  logic [7:0] a, b;
  leafR u_r (.r_pv(rv), .r_lv(lv), .i_pv(a), .o_pv(b));
endmodule
