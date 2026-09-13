// d6 — NESTED struct: a member OF A MEMBER, and a packed-array member element.
package p;
  typedef struct packed { int unsigned w; logic [7:0] t; } inner_t;
  typedef struct packed { int unsigned n; inner_t u; logic [2:0][15:0] arr; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n   = 4;
    r.u   = '{w: 9, t: 8'hA5};
    r.arr = {16'h1111, 16'h2222, 16'h3333};
    return r;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output logic [31:0] o_n,
    output logic [39:0] o_u,
    output logic [31:0] o_uw,
    output logic [7:0]  o_ut,
    output logic [47:0] o_arr,
    output logic [15:0] o_arr0
);
  assign o_n    = CFG.n;
  assign o_u    = CFG.u;        // a STRUCT-typed member read whole
  assign o_uw   = CFG.u.w;      // member OF a member
  assign o_ut   = CFG.u.t;
  assign o_arr  = CFG.arr;
  assign o_arr0 = CFG.arr[0];   // element of a packed-array member
endmodule
