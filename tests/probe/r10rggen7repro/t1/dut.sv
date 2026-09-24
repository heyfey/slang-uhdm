// r10rggen7 t1: does a def-view func_call inside a generate block carry
// vpiFunction?  Two sibling calls to the SAME function: one at module level
// (cont_assign), one inside a generate-if body.  Golden law: module-level call
// binds vpiFunction; the generate-body call does NOT (def view only).
module t1 #(parameter int W = 4)(
  input  logic [W-1:0] i_a,
  output logic [W-1:0] o_top,
  output logic [W-1:0] o_gen
);
  assign o_top = twice(i_a);

  generate if (W > 2) begin : g_blk
    assign o_gen = twice(i_a);
  end endgenerate

  function automatic logic [W-1:0] twice(logic [W-1:0] x);
    return x + x;
  endfunction
endmodule
