// § tpRebindSpanDiffers281
module child #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (
    input  rt_t rt_i,
    output logic sel_o
);
  assign sel_o = ^rt_i;
endmodule
module dut(input logic [255:0] a, output logic o);
  logic [1:0] q;
  child #(.id_t(type(q))) u (.rt_i(a), .sel_o(o));
endmodule
