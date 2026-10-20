// § labeledCallStmtLabelDropped415
module top(input logic clk, input logic [7:0] a, output logic [7:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    task automatic t(input logic [7:0] x); o[i] = x; endtask
    always_ff @(posedge clk) begin
      cl: t(a);
    end
  end
endmodule
