module child #(parameter type T = logic, localparam type W = T [1:0]) (input W a, output W b);
  assign b = a;
endmodule
module dut (input logic [3:0] a, output logic [3:0] b);
  if (1) begin : g
    child #(.T(logic [1:0])) u (.a(a), .b(b));
  end
endmodule
