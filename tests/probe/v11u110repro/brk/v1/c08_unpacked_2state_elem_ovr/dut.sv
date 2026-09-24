module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (input logic [15:0] a, output logic o);
  rt_t x [2];
  assign x[0] = a[7:0];
  assign x[1] = a[15:8];
  assign o = ^x[0] ^ ^x[1];
endmodule
module dut(input logic [15:0] a, output logic o);
  child #(.id_t(bit [1:0])) u (.a(a), .o(o));
endmodule
