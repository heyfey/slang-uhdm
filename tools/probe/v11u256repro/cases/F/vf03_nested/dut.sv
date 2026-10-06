// § patLitFormFileAtRef256 (a nested pattern of package values)
module top(output logic [11:0] o);
  localparam dm::out_t H = '{inner: '{a: dm::DataCount, b: 4'h1}, c: dm::DataCount};
  assign o = H;
endmodule
