// § nestedDefSecondBodyReadsRep307
module inner (output logic r); assign r = 1'b1; endmodule
module outer (output logic o);
  inner u_i (.r(o));
endmodule
module dut (output logic [1:0] o);
  outer u_o (.o(o[0]));
  outer u_p (.o(o[1]));
endmodule
