// § tpRebindSpanDiffers281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t a, output logic o);
  assign o = ^a;
endmodule
module dut(input logic [3:0] a, output logic o, output logic p);
  child #(.id_t(logic)) u (.a(a), .o(o));
  child v (.a(a), .o(p));
endmodule
