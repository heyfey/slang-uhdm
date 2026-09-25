// § tpUseBindsDefDefault160
typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
module leaf #(parameter type T = u_t) (input logic clk, input logic [7:0] d, output logic [7:0] o);
  T q;
  always_ff @(posedge clk) q.a <= d;
  assign o = q.b;
endmodule
module top (input logic clk, input logic [7:0] d, output logic [7:0] o);
  leaf u (.clk(clk), .d(d), .o(o));
endmodule
