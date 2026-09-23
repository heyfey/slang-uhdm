interface ifc #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]);
  rt_t x;
endinterface
module dut (input logic [7:0] a, output logic [7:0] o);
  ifc i();
  assign i.x = a;
  assign o = i.x;
endmodule
