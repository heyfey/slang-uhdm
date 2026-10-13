// § nestedDeepInstStub307
module a_m (output logic [3:0] o);
  module b_m (output logic [3:0] o);
    module c_m #(parameter int W = 1) (output logic [W-1:0] r); assign r = '1; endmodule
    c_m #(.W(4)) u_c (.r(o));
  endmodule
  b_m u_b (.o(o));
endmodule
module dut (output logic [3:0] o);
  a_m u_a (.o(o));
endmodule
