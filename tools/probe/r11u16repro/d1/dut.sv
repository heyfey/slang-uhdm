// d1 — MODULE-HOLDER PARAMETER, function-built packed struct (the corpus shape).
// Every continuous-assignment RHS shape that reads it, on one holder.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 3;
    r.base = 64'h1000;
    return r;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output logic [95:0] o_whole,
    output logic [31:0] o_n,
    output logic [63:0] o_b,
    output logic [31:0] o_part,
    output logic        o_bit,
    output logic [31:0] o_expr,
    output logic [63:0] o_cat,
    output logic [7:0]  o_narrow,
    output logic [63:0] o_wide
);
  assign o_whole  = CFG;            // WHOLE read
  assign o_n      = CFG.n;          // MEMBER select, LHS width == member width
  assign o_b      = CFG.base;       // MEMBER select, 64-bit member
  assign o_part   = CFG.base[31:0]; // PART select of a member
  assign o_bit    = CFG.base[12];   // BIT select of a member
  assign o_expr   = CFG.n + 1;      // EXPRESSION around the read
  assign o_cat    = {CFG.n, CFG.n}; // CONCAT around the read
  assign o_narrow = CFG.n;          // MEMBER select into a NARROWER LHS
  assign o_wide   = CFG.n;          // MEMBER select into a WIDER LHS
endmodule
