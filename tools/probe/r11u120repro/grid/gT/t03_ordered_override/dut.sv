module child #(parameter type T = logic, localparam type W = T [1:0]) (input W a, output W b);
  assign b = a;
endmodule
module dut (input logic [5:0] a, output logic [5:0] b);
  child #(logic [2:0]) u (.a(a), .b(b));
endmodule
