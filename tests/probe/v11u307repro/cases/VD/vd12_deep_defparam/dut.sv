// § nestedDeepInstStub307
module a_m (input logic i, output logic o);
  module b_m (input logic i, output logic o);
    module c_m #(parameter int W = 1) (input logic x, output logic r); assign r = W[0] ^ x; endmodule
    c_m u_c (.x(i), .r(o));
    defparam u_c.W = 2;
  endmodule
  b_m u_b (.i(i), .o(o));
endmodule
module dut (input logic i, output logic o);
  a_m u_a (.i(i), .o(o));
endmodule
