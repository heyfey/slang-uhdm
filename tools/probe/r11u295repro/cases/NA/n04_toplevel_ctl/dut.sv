// § nestedModArrayScopedName295
module inner (output logic r); assign r = 1'b1; endmodule
module dut (output logic [1:0] o);
  inner u_i [1:0] (.r(o));
endmodule
