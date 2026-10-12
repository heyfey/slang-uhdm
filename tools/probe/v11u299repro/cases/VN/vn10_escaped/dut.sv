// § nonAnsiTpVarAtHeader299
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (\rt.i , sel_o);
  input rt_t \rt.i ;
  output logic sel_o;
  assign sel_o = ^\rt.i ;
endmodule
module dut(input logic [7:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.\rt.i (a), .sel_o(o));
endmodule
