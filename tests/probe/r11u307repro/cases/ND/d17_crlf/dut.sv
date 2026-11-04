// § nestedDeepInstStub307
module a_m (output logic o);
  module b_m (output logic o);
    module c_m (output logic r); assign r = 1'b1; endmodule
    c_m u_c (.r(o));
  endmodule
  b_m u_b (.o(o));
endmodule
module dut (output logic o);
  a_m u_a (.o(o));
endmodule
