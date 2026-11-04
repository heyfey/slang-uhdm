// § nestedDeepInstStub307
module a_m (output logic o);
  module b_m (output logic o);
    module c_m #(parameter int P = 1) (); endmodule
    c_m u_c ();
    assign o = 1'b0;
  endmodule
  b_m u_b (.o(o));
endmodule
module dut (output logic o);
  a_m u_a (.o(o));
endmodule
