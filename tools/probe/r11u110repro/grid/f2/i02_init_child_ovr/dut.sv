module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (output logic [7:0] o);
  rt_t x = '1;
  assign o = x;
endmodule
module dut(output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.o(o));
endmodule
