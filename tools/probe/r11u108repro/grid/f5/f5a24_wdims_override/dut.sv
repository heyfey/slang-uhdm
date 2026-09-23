module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t [1:0] r, output logic o);
  rt_t [1:0] y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o);
  child #(.id_t(logic [1:0])) u (.r(r), .o(o));
endmodule
