module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [1:0]
) (
    input  rt_t rt_i,
    output logic sel_o
);
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [15:0] a, input logic [63:0] b, output logic o, output logic p);
  child #(.id_t(byte)) u (.rt_i(a), .sel_o(o));
  child #(.id_t(int unsigned)) v (.rt_i(b), .sel_o(p));
endmodule
