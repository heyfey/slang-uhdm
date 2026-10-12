// § nonAnsiTpVarAtHeader299
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (rt_o, sel_i);
  output rt_t rt_o;
  input logic sel_i;
  assign rt_o = {4{sel_i}};
endmodule
module dut(input logic i, output logic [3:0] o);
  child u (.rt_o(o), .sel_i(i));
endmodule
