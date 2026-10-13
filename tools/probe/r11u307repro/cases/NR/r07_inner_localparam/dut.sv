// § nestedDefSecondBodyReadsRep307
module outer (output logic [3:0] y);
  module inner (output logic [3:0] o);
    localparam logic [3:0] K = 4'd9;
    assign o = K;
  endmodule
  inner u_i (.o(y));
endmodule
module dut (output logic [7:0] y);
  outer u_o (.y(y[3:0]));
  outer u_p (.y(y[7:4]));
endmodule
