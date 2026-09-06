// r10earl105 h2 — the SAME shape in a CHILD instance (Earlgrey's u_pinmux).
module h2_leaf105 (
  input  logic [31:0] periph_to_mio_i,
  output logic [3:0]  mio_out_o
);
  localparam int NP = 32;
  localparam logic [NP-1:0] MioPeriphHasSleepMode = {NP{1'b1}};

  for (genvar k = 0; k < 4; k++) begin : gen_mio_out
    logic [63:0] data_mux, sleep_mux;
    assign data_mux  = $bits(data_mux)'({periph_to_mio_i, 1'b0, 1'b1, 1'b0});
    assign sleep_mux = $bits(sleep_mux)'({MioPeriphHasSleepMode, 1'b1, 1'b1, 1'b1});
    assign mio_out_o[k] = sleep_mux[0] & data_mux[0];
  end
endmodule

module h2_child105 (
  input  logic [31:0] a,
  output logic [3:0]  z
);
  h2_leaf105 u_leaf (.periph_to_mio_i(a), .mio_out_o(z));
endmodule
