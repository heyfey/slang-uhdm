// § tpRebindSpanDiffers281
interface ifc #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]);
  rt_t x;
endinterface
module dut(input logic [3:0] a, output logic [3:0] o);
  ifc #(.id_t(logic)) u();
  assign u.x = a;
  assign o = u.x;
endmodule
