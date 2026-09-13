// d4 — d1's BAIL twin.  A 1024-bit member makes the v1.87 assembler
// (reduceExpr's uhdmstruct_var arm) give up, the parameter stays a struct_var,
// and no continuous-assignment RHS can fold.  Nothing here may move.
package p;
  typedef struct packed {
    int unsigned      n;
    logic [15:0][63:0] wide;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 3;
    r.wide = '0;
    return r;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output logic [31:0] o_n,
    output logic [63:0] o_w0,
    output logic [31:0] o_expr
);
  assign o_n    = CFG.n;
  assign o_w0   = CFG.wide[0];
  assign o_expr = CFG.n + 1;
endmodule
