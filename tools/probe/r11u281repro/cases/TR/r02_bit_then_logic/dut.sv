// § tpRebindSpanDiffers281
module child #(
    parameter type id_t = logic [1:0],
    localparam type rt_t = id_t [1:0]
) (
    input  rt_t rt_i,
    output logic sel_o
);
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [3:0] a, output logic o, output logic p);
  child #(.id_t(bit [1:0])) u (.rt_i(a), .sel_o(o));
  child #(.id_t(logic [1:0])) v (.rt_i(a), .sel_o(p));
endmodule
