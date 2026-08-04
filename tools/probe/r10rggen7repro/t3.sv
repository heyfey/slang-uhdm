// r10rggen7 t3: def-view generate-body PROCESS containing (a) a task call and
// (b) a system-function call, next to a module-level process with the same
// pair.  Splits "does the def-gen process bind vpiTask too?" from the
// func_call law of t2, and checks whether the node KIND changes.
module t3 #(parameter int W = 4)(
  input  logic clk,
  input  logic [W-1:0] i_a,
  output logic [W-1:0] o_top,
  output logic [W-1:0] o_gen
);
  always_ff @(posedge clk) begin
    bump(i_a);
  end

  generate
    if (W > 2) begin : g_proc
      always_ff @(posedge clk) begin
        bump(i_a);
      end
    end
  endgenerate

  task automatic bump(input logic [W-1:0] y);
    $display("%0d", y);
  endtask
endmodule
