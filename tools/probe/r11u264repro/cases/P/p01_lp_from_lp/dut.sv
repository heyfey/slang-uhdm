// § elabParamRefSignedTsUnlocated264
module sub #(parameter int D = 16) (output logic [7:0] o);
  localparam int AW = $clog2(D);
  localparam int NB = (D * 8) / 32;
  localparam int NBW = $clog2(NB);
  localparam int AVW = NBW;
  localparam int AVD = 4;
  localparam int RXW = NBW + (1 + AW) + 4 + 1;
  assign o = AVW + RXW + AVD;
endmodule
module top(output logic [7:0] o);
  sub u(.o(o));
endmodule
