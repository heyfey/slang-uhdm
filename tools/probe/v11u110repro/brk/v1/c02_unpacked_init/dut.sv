module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  rt_t x [2] = '{8'h1, 8'h2};
  assign o = ^x[0] ^ ^x[1] ^ ^a;
endmodule
module dut(input logic [15:0] a, output logic o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
