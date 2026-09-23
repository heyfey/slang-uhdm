module child #(parameter type id_t = logic [1:0], parameter type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [7:0] a, output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  child u1 (.a(a), .o(o1));
  child #(.rt_t(logic [7:0])) u2 (.a(a), .o(o2));
  child #(.id_t(logic [3:0])) u3 (.a(a), .o(o3));
endmodule
