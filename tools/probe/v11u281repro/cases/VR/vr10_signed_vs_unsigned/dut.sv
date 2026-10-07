// § tpRebindSpanDiffers281
module child #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [1:0]) (input rt_t a, output logic o);
  assign o = ^a;
endmodule
module dut(input logic [3:0] a, output logic o);
  child #(.id_t(logic signed [1:0])) u (.a(a), .o(o));
endmodule
