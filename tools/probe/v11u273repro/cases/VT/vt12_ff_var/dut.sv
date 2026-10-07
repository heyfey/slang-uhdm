// § typeParamStructLastNetParent273
module dut (input logic clk, input logic [4:0] i, output logic [4:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  T q;
  always_ff @(posedge clk) q <= i;
  assign o = q.a + q.b;
endmodule
