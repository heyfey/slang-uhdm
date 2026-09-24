module dut #(
    parameter type id_t = logic,
    localparam type rt_t = id_t [3:0]
) (
    input  rt_t rt_i,
    output logic sel_o
);
  assign sel_o = ^rt_i;
endmodule
