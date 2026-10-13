// § nestedDeepInstStub307
module a_m (input logic x, output logic r);
  module b_m (input logic x, output logic r);
    module c_m (input logic x, output logic r); assign r = ~x; endmodule
    c_m u_c (.*);
  endmodule
  b_m u_b (.x(x), .r(r));
endmodule
module dut (input logic i, output logic o);
  a_m u_a (.x(i), .r(o));
endmodule
