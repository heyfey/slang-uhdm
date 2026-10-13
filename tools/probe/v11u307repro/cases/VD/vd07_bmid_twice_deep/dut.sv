// § nestedDeepInstStub307
module a_m (input logic [1:0] i, output logic [1:0] o);
  module b_m (input logic i, output logic o);
    module c_m (input logic x, output logic r); assign r = ~x; endmodule
    c_m u_c (.x(i), .r(o));
  endmodule
  b_m u_b0 (.i(i[0]), .o(o[0]));
  b_m u_b1 (.i(i[1]), .o(o[1]));
endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  a_m u_a0 (.i(i[1:0]), .o(o[1:0]));
  a_m u_a1 (.i(i[3:2]), .o(o[3:2]));
endmodule
