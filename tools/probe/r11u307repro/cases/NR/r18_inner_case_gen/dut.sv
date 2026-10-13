// § nestedDefSecondBodyReadsRep307
module outer #(parameter int M = 0) (output logic [1:0] o);
  module inner (output logic [1:0] r); assign r = 2'd2; endmodule
  if (M == 0) begin : g0
    inner u_i (.r(o));
  end else begin : g1
    assign o = 2'd1;
  end
endmodule
module dut (output logic [3:0] o);
  outer #(.M(0)) u_o (.o(o[1:0]));
  outer #(.M(0)) u_p (.o(o[3:2]));
endmodule
