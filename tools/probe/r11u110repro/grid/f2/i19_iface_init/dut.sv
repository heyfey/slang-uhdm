interface ifc #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]);
  rt_t x = 8'h5a;
endinterface
module dut (output logic [7:0] o);
  ifc i();
  assign o = i.x;
endmodule
