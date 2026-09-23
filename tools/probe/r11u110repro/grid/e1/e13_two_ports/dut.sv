module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (
    input  rt_t a_i,
    input  rt_t b_i,
    output logic sel_o
);
  assign sel_o = ^(a_i ^ b_i);
endmodule
module dut(input logic [7:0] a, input logic [7:0] b, output logic o);
  child #(.id_t(logic [1:0])) u (.a_i(a), .b_i(b), .sel_o(o));
endmodule
