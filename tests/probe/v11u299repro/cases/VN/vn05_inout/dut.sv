// § nonAnsiTpVarAtHeader299
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (rt_io, sel_o);
  inout tri rt_t rt_io;
  output logic sel_o;
  assign sel_o = ^rt_io;
endmodule
module dut(inout wire [7:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.rt_io(a), .sel_o(o));
endmodule
