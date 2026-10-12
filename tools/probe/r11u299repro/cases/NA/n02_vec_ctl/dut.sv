// § nonAnsiTpVarAtHeader299
module child (rt_i, sel_o);
  input logic [3:0] rt_i;
  output logic sel_o;
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [3:0] a, output logic o);
  child u (.rt_i(a), .sel_o(o));
endmodule
