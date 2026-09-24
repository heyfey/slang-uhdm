module child #(
    parameter type id_t = logic,
    parameter type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  rt_t x = 8'h5a;
  assign o = ^x ^ ^a;
endmodule
module dut(input logic [15:0] a, output logic o, output logic p);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
  child #(.rt_t(logic [5:0])) v (.a(a), .o(p));
endmodule
