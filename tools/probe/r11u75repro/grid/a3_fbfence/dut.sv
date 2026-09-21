// r11u74 a3 — LAW A's FENCES in a generate scope, each with its module-level
// twin.  Every row here is one this law must NOT fold, or must fold exactly as
// the module-level home already does.
package p;
  typedef struct packed { int unsigned w; logic [7:0] t; } inner_t;
  typedef struct packed { int unsigned n; inner_t u; } nest_t;   // d13's shape
  typedef struct packed { int unsigned n; int unsigned m; } flat_t;
  function automatic nest_t bnest(int unsigned x);
    nest_t r;
    r.n = x;
    r.u = '{w: 9, t: 8'hA5};      // the NAMED pattern that makes assemble() bail
    return r;
  endfunction
  function automatic flat_t bflat(int unsigned x);
    flat_t c;
    c.n = x;
    c.m = $clog2(x / 8);
    return c;
  endfunction
  localparam nest_t NST = bnest(64);
  localparam flat_t FB  = bflat(64);
  localparam flat_t LIT = '{n: 3, m: 4};   // NOT function-built (r11u69's law)
endpackage
module dut #(parameter p::nest_t NS = p::NST,
             parameter p::flat_t FBP = p::FB,
             parameter p::flat_t LP = p::LIT)
  (output logic [31:0] t_nest, g_nest,
   output logic [31:0] t_op,   g_op,
   output logic [31:0] t_cat,  g_cat,
   output logic [31:0] t_deep, g_deep,
   output logic [31:0] t_lit,  g_lit,
   output logic [31:0] t_bit,  g_bit,
   output logic [31:0] t_arr [0:1], g_arr [0:1]);
  assign t_nest = NS.n;            // struct-bearing struct: the d13 fence
  assign t_op   = FBP.n + 1;       // an operation AROUND the member select
  assign t_cat  = {16'd0, FBP.n[15:0]};   // a concat around it
  assign t_deep = NS.u.w;          // a member OF a member
  assign t_lit  = LP.n;            // the pattern-built twin (r11u69's law)
  assign t_bit[0] = FBP.n;         // bit-select Lhs
  assign t_arr[0] = FBP.n;         // array-element Lhs
  if (1) begin : gb
    assign g_nest = NS.n;
    assign g_op   = FBP.n + 1;
    assign g_cat  = {16'd0, FBP.n[15:0]};
    assign g_deep = NS.u.w;
    assign g_lit  = LP.n;
    assign g_bit[0] = FBP.n;
    assign g_arr[0] = FBP.n;
  end
endmodule
