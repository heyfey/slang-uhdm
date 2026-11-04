// § tpRebindSpanDiffers281
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t a, output logic o);
  assign o = ^a;
endmodule
module mid #(parameter type id_t = logic [1:0]) (input logic [3:0] a, output logic o);
  child c (.a(a), .o(o));
endmodule
module dut(input logic [3:0] a, output logic o);
  mid #(.id_t(logic)) m (.a(a), .o(o));
endmodule
