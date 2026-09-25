// § defNetTypeParamPackedVec160
module top #(parameter type T = logic [7:0]) (input logic clk, input logic [15:0] d, output logic [15:0] o);
  if (1) begin : g
    T [1:0] q;
    always_ff @(posedge clk) q <= d;
    assign o = q;
  end
endmodule
