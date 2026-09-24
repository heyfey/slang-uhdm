module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [7:0] r, output logic o);
  child #(.id_t(bit [1:0])) u (.r(r), .o(o));
endmodule
