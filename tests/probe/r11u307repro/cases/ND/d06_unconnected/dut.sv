// § nestedDeepInstStub307
module a_m (input logic i, output logic o);
  module b_m (input logic i, output logic o);
    module c_m (input logic x, output logic r, output logic s); assign r = ~x; assign s = x; endmodule
    c_m u_c (.x(i), .r(o), .s());
  endmodule
  b_m u_b (.i(i), .o(o));
endmodule
module dut (input logic i, output logic o);
  a_m u_a (.i(i), .o(o));
endmodule
