module child #(
    parameter type id_t = logic,
    parameter type jd_t = logic,
    localparam type rt_t = id_t [3:0],
    localparam type st_t = jd_t [1:0]
) (
    input  rt_t rt_i,
    input  st_t st_i,
    output logic sel_o
);
  assign sel_o = ^rt_i ^ ^st_i;
endmodule
module dut(input logic [63:0] a, output logic o, output logic p);
  child #(.id_t(logic [1:0]), .jd_t(logic [2:0])) u (.rt_i(a), .st_i(a), .sel_o(o));
  child #(.jd_t(logic [3:0])) v (.rt_i(a), .st_i(a), .sel_o(p));
endmodule
