// § tpPatNestNamedChain281v
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic a, output logic o);
  rt_t x [2];
  assign x[0] = {8{a}}; assign x[1] = x[0];
  assign o = x[1][0];
endmodule
module dut(input logic a, output logic o);
  child #(logic [1:0]) u (.a(a), .o(o));
endmodule
