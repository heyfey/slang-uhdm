// § nonAnsiTpVarAtHeader299
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (a, b, sel_o);
  input rt_t a, b;
  output logic sel_o;
  assign sel_o = ^a ^ ^b;
endmodule
module dut(input logic [7:0] x, output logic o);
  child #(.id_t(logic [1:0])) u (.a(x), .b(x), .sel_o(o));
endmodule
