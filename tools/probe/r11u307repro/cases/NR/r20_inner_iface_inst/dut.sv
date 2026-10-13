// § nestedDefSecondBodyReadsRep307
interface ib; logic v; endinterface
module outer (output logic o);
  module inner (output logic r);
    ib x ();
    assign x.v = 1'b1;
    assign r = x.v;
  endmodule
  inner u_i (.r(o));
endmodule
module dut (output logic [1:0] o);
  outer u_o (.o(o[0]));
  outer u_p (.o(o[1]));
endmodule
