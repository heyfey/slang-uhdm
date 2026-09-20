// r11u69 g8 — THE FENCES, re-homed inside generate blocks.  Each row is a
// shape the pass-54 law DECLINES at module level; golden must decline it in a
// generate block too, or the fence is wrong.
//   f_func  a FUNCTION-BUILT struct parameter (§ caAsmMemberSliceFold's ground,
//           and the shape corpus row struct_param_field_shift writes)
//   f_cast  an EXPLICIT CAST in the initializer chain (the r11v55 cast fence)
//   f_var   a struct VARIABLE's field (not constant)
//   f_ridx  a non-constant array index
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
  localparam cfg_t OTHER = '{n: 9, m: 10};
endpackage

module leaf #(parameter p::cfg_t C = p::LIT)
  (output logic [31:0] o_c);
  if (1) begin : gl
    assign o_c = C.n;
  end
endmodule

module dut #(parameter p::cfg_t FB = p::BUILT)
  (input  logic [3:0]  sel_i,
   output logic [31:0] o_func,
   output logic [31:0] o_var,
   output logic [31:0] o_ridx,
   output logic [31:0] o_leaf);

  p::cfg_t vcfg;
  int unsigned arr [0:3];

  if (1) begin : gf
    assign o_func = FB.n;          // function-built  -> pass-54 fence
    assign o_var  = vcfg.n;        // struct VARIABLE -> not constant
    assign o_ridx = arr[sel_i];    // non-constant index
  end

  leaf #(.C(p::cfg_t'(p::OTHER))) u_c (.o_c(o_leaf));   // explicit-cast fence
endmodule
