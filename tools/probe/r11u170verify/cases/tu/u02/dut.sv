// § tpUseBindsDefDefault160
package pk; typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t; endpackage
module sub #(parameter type T = pk::s_t) (input logic clk, output logic [15:0] o);
  for (genvar g = 0; g < 2; g++) begin : G
    T q;
    always_ff @(posedge clk) q <= '0;
    assign o[g*8 +: 8] = q;
  end
endmodule
module top (input logic clk, output logic [15:0] o); sub u(.clk(clk), .o(o)); endmodule
