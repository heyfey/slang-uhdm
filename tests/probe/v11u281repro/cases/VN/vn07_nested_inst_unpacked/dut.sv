// § defNetTpPatNestedSig281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [7:0] a, output logic [7:0] o);
  rt_t x [2];
  assign x[0] = a; assign x[1] = a;
  assign o = x[1];
endmodule
module mid #(parameter type id_t = logic) (input logic [7:0] a, output logic [7:0] o);
  child #(.id_t(id_t)) c (.a(a), .o(o));
endmodule
module dut(input logic [7:0] a, output logic [7:0] o);
  mid #(.id_t(logic [1:0])) m (.a(a), .o(o));
endmodule
