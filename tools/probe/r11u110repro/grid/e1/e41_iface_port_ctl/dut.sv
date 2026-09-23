interface ifc #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t r);
endinterface
module dut(input logic [7:0] a);
  ifc #(.id_t(logic [1:0])) i0 (.r(a));
endmodule
