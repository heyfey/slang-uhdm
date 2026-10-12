// § nonAnsiTpVarAtHeader299
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (rt_i, sel_o);
  input rt_t rt_i;
  output logic sel_o;
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [7:0] a, output logic [1:0] o);
  for (genvar k = 0; k < 2; k++) begin : gg
    child #(.id_t(logic [1:0])) u (.rt_i(a), .sel_o(o[k]));
  end
endmodule
