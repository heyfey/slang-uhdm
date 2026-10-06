// § patLitFormFileAtRef256 (the struct type and the value in two other files)
module top(output logic [7:0] o);
  localparam tp::pair_t H = '{x: dm::DataCount, y: dm::DataCount};
  assign o = H;
endmodule
