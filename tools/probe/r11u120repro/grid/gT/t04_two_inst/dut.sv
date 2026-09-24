module child #(parameter type T = logic, localparam type W = T [1:0]) (input W a, output W b);
  assign b = a;
endmodule
module dut (input logic [3:0] a, output logic [3:0] b, input logic [7:0] c, output logic [7:0] d);
  child #(.T(logic [1:0])) u1 (.a(a), .b(b));
  child #(.T(logic [3:0])) u2 (.a(c), .b(d));
endmodule
