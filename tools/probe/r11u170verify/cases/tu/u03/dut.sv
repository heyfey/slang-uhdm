// § tpUseBindsDefDefault160
typedef union packed { logic [7:0] w; struct packed { logic [3:0] hi; logic [3:0] lo; } p; } u_t;
module sub #(parameter type T = u_t) (input logic clk, output logic [7:0] o);
  T q;
  always_ff @(posedge clk) q.w <= '0;
  assign o = q.p.hi;
endmodule
module top (input logic clk, output logic [7:0] o); sub u(.clk(clk), .o(o)); endmodule
