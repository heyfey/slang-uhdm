// t6 — the read used as a RANGE BOUND of a type parameter and of a net, and
// inside a $bits / concat, beside the plain reads.  The landed
// § typeParamDefaultBoundNoReduce18 law must stay: a type parameter's own
// default bound is NOT reduced.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mk();
    c_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module dut #(
    parameter  pk::c_t CFG   = pk::C,
    localparam int     SW    = CFG.a,
    localparam type    sel_t = logic [SW-1:0],        // symbolic bound (r11u20)
    localparam type    dir_t = logic [CFG.a-1:0],     // bound READS the member
    localparam int     NB    = $bits(sel_t)
) (
    input  sel_t s_i,
    input  dir_t d_i,
    output logic o
);
  logic [CFG.b-1:0] w;                                // net range reads a member
  assign w = '0;
  assign o = ^{s_i, d_i, w[0], NB[0]};
endmodule
