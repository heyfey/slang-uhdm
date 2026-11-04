// § nestedDeepInstStub307
module a_m (input logic [1:0] i, output logic [1:0] o);
  module b_m (input logic [1:0] i, output logic [1:0] o);
    module c_m (input logic x, output logic r); assign r = ~x; endmodule
    for (genvar k = 0; k < 2; k++) begin : g
      c_m u_c (.x(i[k]), .r(o[k]));
    end
  endmodule
  b_m u_b (.i(i), .o(o));
endmodule
module dut (input logic [1:0] i, output logic [1:0] o);
  a_m u_a (.i(i), .o(o));
endmodule
