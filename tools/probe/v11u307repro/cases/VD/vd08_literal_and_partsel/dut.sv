// § nestedDeepInstStub307
module a_m (input logic [3:0] i, output logic o);
  module b_m (input logic [3:0] i, output logic o);
    module c_m (input logic [1:0] x, input logic e, output logic r); assign r = ^x & e; endmodule
    c_m u_c (.x(i[3:2]), .e(1'b1), .r(o));
  endmodule
  b_m u_b (.i(i), .o(o));
endmodule
module dut (input logic [3:0] i, output logic o);
  a_m u_a (.i(i), .o(o));
endmodule
