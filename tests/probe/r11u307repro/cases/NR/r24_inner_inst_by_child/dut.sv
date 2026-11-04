// § nestedDefSecondBodyReadsRep307
module outer (output logic [1:0] o);
  module inner (output logic r); assign r = 1'b1; endmodule
  inner u_i (.r(o[0]));
  inner u_j (.r(o[1]));
endmodule
module dut (output logic [5:0] o);
  outer u_o (.o(o[1:0]));
  outer u_p (.o(o[3:2]));
  outer u_q (.o(o[5:4]));
endmodule
