module child #(
    parameter type id_t = logic,
    parameter type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  rt_t x [2];
  assign x[0] = a;
  assign x[1] = a;
  assign o = ^x[0] ^ ^x[1];
endmodule
module dut(input logic [15:0] a, output logic o, output logic p);
  child #(.rt_t(logic [5:0])) u (.a(a), .o(o));
  child #(.rt_t(int)) v (.a(a), .o(p));
endmodule
