// § nestedDefSecondBodyReadsRep307
interface bus_if; logic v; endinterface
module outer (bus_if b, output logic o);
  module inner (input logic i, output logic r); assign r = i; endmodule
  inner u_i (.i(b.v), .r(o));
endmodule
module dut (output logic [1:0] o);
  bus_if b0 ();
  bus_if b1 ();
  outer u_o (.b(b0), .o(o[0]));
  outer u_p (.b(b1), .o(o[1]));
endmodule
