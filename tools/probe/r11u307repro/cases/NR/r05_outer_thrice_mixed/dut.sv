// § nestedDefSecondBodyReadsRep307
module outer #(parameter bit P = 0) (output logic o);
  module inner (output logic r); assign r = 1'b1; endmodule
  inner u_i (.r(o));
endmodule
module dut (output logic [2:0] o);
  outer u_a (.o(o[0]));
  outer #(.P(1)) u_b (.o(o[1]));
  outer u_c (.o(o[2]));
endmodule
