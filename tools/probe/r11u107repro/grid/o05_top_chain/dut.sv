module dut #(
    parameter type id_t     = logic [1:0],
    parameter type resp_id_t = id_t,
    localparam int DEPTH    = (1 << $bits(resp_id_t)),
    localparam type rt_t    = resp_id_t [DEPTH-1:0]
) (input resp_id_t id_i, input rt_t rt_i, output logic o);
  assign o = ^{id_i, rt_i};
endmodule
