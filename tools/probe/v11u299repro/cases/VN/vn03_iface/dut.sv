// § nonAnsiTpVarAtHeader299
interface ifc #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (rt_i);
  input rt_t rt_i;
  logic s;
  assign s = ^rt_i;
endinterface
module dut(input logic [7:0] a, output logic o);
  ifc #(.id_t(logic [1:0])) u (a);
  assign o = u.s;
endmodule
