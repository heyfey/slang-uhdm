module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t a = '0, output logic [7:0] o);
  assign o = a;
endmodule
module dut(output logic [7:0] o);
  child #(.id_t(logic [1:0])) u (.o(o));
endmodule
