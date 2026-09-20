// r11u69 g12 — THE FENCE TWINS.  Every g8 row, written ONCE at module level
// and ONCE inside a generate block, so the question "does the module-level law
// already serve this shape?" is answered per row instead of assumed.  Parity
// is the target: whatever the module-level row does today, the generate row
// must do after this pass, and nothing more.
package p;
  typedef struct packed { int unsigned n; int unsigned m; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.n = x;
    c.m = $clog2(x / 8);
    return c;
  endfunction
  localparam cfg_t BUILT = build(64);
  localparam cfg_t LIT   = '{n: 3, m: 4};
endpackage

module dut #(parameter p::cfg_t FB = p::BUILT,
             parameter p::cfg_t LP = p::LIT)
  (input  logic [3:0]  sel_i,
   output logic [31:0] t_func, g_func,
   output logic [31:0] t_var,  g_var,
   output logic [31:0] t_lit,  g_lit,
   output logic [31:0] t_bit,  g_bit,
   output logic [31:0] t_arr [0:1], g_arr [0:1]);

  p::cfg_t vcfg;

  assign t_func   = FB.n;        // function-built, module level
  assign t_var    = vcfg.n;      // struct VARIABLE, module level
  assign t_lit    = LP.n;        // the landed law's own shape, module level
  assign t_bit[0] = LP.n;        // bit-select Lhs, module level
  assign t_arr[0] = LP.n;        // array-element Lhs, module level

  if (1) begin : gblk
    assign g_func   = FB.n;
    assign g_var    = vcfg.n;
    assign g_lit    = LP.n;
    assign g_bit[0] = LP.n;
    assign g_arr[0] = LP.n;
  end
endmodule
