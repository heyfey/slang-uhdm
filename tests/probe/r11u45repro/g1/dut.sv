// g1 — depth-1 chain, keyword element with a packed dim (the corpus shape).
module dut #(
    parameter type id_t      = logic [1:0],
    parameter type resp_id_t = id_t
) ( input resp_id_t i, output logic o );
  assign o = ^i;
endmodule
