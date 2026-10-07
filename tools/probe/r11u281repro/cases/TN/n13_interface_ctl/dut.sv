// § defNetTpPatNestedSig281
interface ifc #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]);
  rt_t x [2];
endinterface
module dut(input logic [7:0] a, output logic [7:0] o);
  ifc #(.id_t(logic [1:0])) u();
  assign u.x[0] = a;
  assign o = u.x[0];
endmodule
