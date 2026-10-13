// § nestedDeepInstStub307
interface ib; logic v; endinterface
module a_m (output logic o);
  module b_m (output logic o);
    module c_m (ib x, output logic r); assign r = x.v; endmodule
    ib w ();
    c_m u_c (.x(w), .r(o));
  endmodule
  b_m u_b (.o(o));
endmodule
module dut (output logic o);
  a_m u_a (.o(o));
endmodule
