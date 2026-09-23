module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0],
    localparam type qt_t = rt_t [1:0]
) (
    input  qt_t q_i,
    input  rt_t r_i,
    output logic sel_o
);
  assign sel_o = ^q_i ^ ^r_i;
endmodule
module dut(input logic [15:0] a, input logic [7:0] b, output logic o);
  child #(.id_t(logic [1:0])) u (.q_i(a), .r_i(b), .sel_o(o));
endmodule
