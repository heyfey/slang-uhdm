// § nestedDeepInstStub307
module a_m (output logic [1:0] o);
  module b_m (output logic o);
    module c_m (output logic r); assign r = 1'b1; endmodule
    c_m u_c (.r(o));
  endmodule
  b_m u_b0 (.o(o[0]));
  b_m u_b1 (.o(o[1]));
endmodule
module dut (output logic [1:0] o);
  a_m u_a (.o(o));
endmodule
