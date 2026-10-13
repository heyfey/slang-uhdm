// § nestedDefSecondBodyReadsRep307
module outer (output logic o);
  module inner (output logic r); assign r = 1'b0; endmodule
  inner u_i (.r(o));
endmodule
module mid (output logic [1:0] o);
  outer u_x (.o(o[0]));
  outer u_y (.o(o[1]));
endmodule
module dut (output logic [3:0] o);
  mid u_m0 (.o(o[1:0]));
  mid u_m1 (.o(o[3:2]));
endmodule
