// § nonAnsiTpVarAtHeader299
module child (rt_i, sel_o);
  typedef logic [1:0] id_t;
  input id_t [3:0] rt_i;
  output logic sel_o;
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [7:0] a, output logic o);
  child u (.rt_i(a), .sel_o(o));
endmodule
