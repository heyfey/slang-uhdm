// § defNetTpPatNestedSig281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x [1:0][1:0];
  assign x[0][0] = a; assign x[0][1] = a; assign x[1][0] = a; assign x[1][1] = a;
  assign o = x[1][1];
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
