// § nestedDeepInstStub307
module a_m (output logic o);
  module b_m (output logic o);
    module c_m (input logic x, output logic r); assign r = x; endmodule
    c_m u_c (.x(1'b1), .r(o));
  endmodule
  b_m u_b (.o(o));
endmodule
module dut (output logic o);
  a_m u_a (.o(o));
endmodule
