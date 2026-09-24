module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (
    input  rt_t rt_i,
    output logic sel_o
);
  rt_t q;
  assign q = rt_i;
  assign sel_o = ^q;
endmodule
module dut(input logic [15:0] a, output logic o, output logic p);
  child #(.id_t(logic [3:0])) u (.rt_i(a), .sel_o(o));
  child #(.id_t(logic [1:0])) v (.rt_i(a[7:0]), .sel_o(p));
endmodule
