// r10rggen7 t2: same question as t1 but the generate-body call sits inside a
// PROCEDURAL block (always_ff) rather than a cont_assign.  Rggen's
// rggen_adapter_common:89 is this shape and we bound vpiFunction where golden
// did not.
module t2 #(parameter int W = 4)(
  input  logic clk,
  input  logic [W-1:0] i_a,
  output logic [W-1:0] o_top,
  output logic [W-1:0] o_gen
);
  assign o_top = twice(i_a);

  generate
    if (W > 2) begin : g_proc
      always_ff @(posedge clk) begin
        o_gen <= twice(i_a);
      end
    end
    else begin : g_ca
      assign o_gen = twice(i_a);
    end
  endgenerate

  function automatic logic [W-1:0] twice(logic [W-1:0] x);
    return x + x;
  endfunction
endmodule
