// § typeParamStructLastNetParent273
module top(input logic clk, input logic [31:0] d, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; };
  my_t r;
  always_ff @(posedge clk) r <= '{a: d, b: 16'd0};
  assign o = r.a;
endmodule
