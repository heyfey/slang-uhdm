// § nestedDefSecondBodyReadsRep307
module outer (input logic a, output logic o);
  module inner (input logic i, output logic r); assign r = ~i; endmodule
  inner u_i (.i(a), .r(o));
endmodule
module dut (input logic [2:0] a, output logic [2:0] o);
  for (genvar k = 0; k < 3; k++) begin : g
    outer u_o (.a(a[k]), .o(o[k]));
  end
endmodule
