// § nonAnsiTpVarAtHeader299
module child #(parameter type rt_t = logic [3:0]) (rt_i, sel_o);
  input rt_t rt_i;
  output logic sel_o;
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [7:0] a, output logic o);
  child #(.rt_t(logic [7:0])) u (.rt_i(a), .sel_o(o));
endmodule
