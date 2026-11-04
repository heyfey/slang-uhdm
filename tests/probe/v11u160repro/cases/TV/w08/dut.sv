// § tpUseBindsDefDefault160
module leaf #(parameter type T = logic [7:0]) (input logic clk, input logic [15:0] d, output logic [15:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    T q;
    always_ff @(posedge clk) q <= d[i*8 +: 8];
    assign o[i*8 +: 8] = q;
  end
endmodule
module top (input logic clk, input logic [15:0] d, output logic [15:0] o);
  leaf u (.clk(clk), .d(d), .o(o));
endmodule
