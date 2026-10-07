// § tpRebindSpanDiffers281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [3:0] a, output logic [3:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut(input logic [3:0] a, output logic [3:0] o);
  child #(.id_t(logic)) u (.a(a), .o(o));
endmodule
