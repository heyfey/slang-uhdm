// § nestedDeepInstStub307
module a_m (input logic [3:0] i, output logic [1:0] o);
  module b_m (input logic [3:0] i, output logic [1:0] o);
    module c_m (input logic x, input logic [1:0] y, output logic r); assign r = x ^ ^y; endmodule
    c_m u_c (.x(i[0] ^ i[3]), .y(i[2 +: 2]), .r(o[1]));
  endmodule
  b_m u_b (.i(i), .o(o));
endmodule
module dut (input logic [3:0] i, output logic [1:0] o);
  a_m u_a (.i(i), .o(o));
endmodule
