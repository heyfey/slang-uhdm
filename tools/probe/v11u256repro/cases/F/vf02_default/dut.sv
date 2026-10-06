// § patLitFormFileAtRef256 (a default: pattern key)
module top(output logic [7:0] o);
  localparam dm::in_t H = '{default: dm::DataCount};
  assign o = H;
endmodule
