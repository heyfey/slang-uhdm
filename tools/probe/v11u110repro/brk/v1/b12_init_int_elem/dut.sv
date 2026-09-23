module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  rt_t x = 32'd7;
  assign o = ^x ^ ^a;
endmodule
module dut(input logic [15:0] a, output logic o);
  child #(.id_t(int)) u (.a(a), .o(o));
endmodule
