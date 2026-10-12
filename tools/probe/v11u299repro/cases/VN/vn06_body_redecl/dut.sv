// § nonAnsiTpVarAtHeader299
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (rt_o, sel_o);
  output rt_o;
  rt_t rt_o;
  output logic sel_o;
  assign rt_o = '1;
  assign sel_o = ^rt_o;
endmodule
module dut(output logic [7:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.rt_o(a), .sel_o(o));
endmodule
