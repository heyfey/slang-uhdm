// § nestedModArrayScopedName295
module outer (output logic [1:0] o);
  module inner (output logic r); assign r = 1'b1; endmodule
  if (1) begin : g
    inner u_i [1:0] (.r(o));
  end
endmodule
module dut (output logic [1:0] o);
  outer u_o (.o(o));
endmodule
