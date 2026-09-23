module leaf #(parameter type rt_t = logic) (input rt_t i, output rt_t o);
  rt_t r;
  assign r = i;
  assign o = r;
endmodule
module mid #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input rt_t i, output rt_t o);
  leaf #(.rt_t(rt_t)) l (.i(i), .o(o));
endmodule
module dut (input logic [7:0] a, output logic [7:0] o);
  mid m (.i(a), .o(o));
endmodule
