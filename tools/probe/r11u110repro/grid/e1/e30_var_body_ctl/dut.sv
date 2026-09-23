module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [7:0] a_i, output logic sel_o);
  rt_t x;
  assign x = a_i;
  assign sel_o = ^x;
endmodule
module dut(input logic [7:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.a_i(a), .sel_o(o));
endmodule
