// § patLitFormFileAtRef256 (an enum constant from another file as a member)
module top(output logic [7:0] o);
  localparam dm::me_t H = '{m: dm::MB, c: dm::DataCount};
  assign o = H;
endmodule
