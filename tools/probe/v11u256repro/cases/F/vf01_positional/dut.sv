// § patLitFormFileAtRef256 (a positional pattern of package values)
module top(output logic [19:0] o);
  localparam dm::hartinfo_t H = '{4'h0, dm::DataCount, dm::DataAddr};
  assign o = H;
endmodule
