module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  rt_t x = '1;
  assign o = ^x ^ ^a;
endmodule
module dut(input logic [15:0] a, output logic o, output logic p);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
  child v (.a(a), .o(p));
endmodule
