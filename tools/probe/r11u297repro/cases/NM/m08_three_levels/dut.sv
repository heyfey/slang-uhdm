// § nestedDefPortsNeedShell297
module a_m (output logic o);
  module b_m (output logic o);
    module c_m (output logic o);
      module d_m (output logic r); assign r = 1'b1; endmodule
      d_m u_d (.r(o));
    endmodule
    c_m u_c (.o(o));
  endmodule
  b_m u_b (.o(o));
endmodule
module dut (output logic o);
  a_m u_a (.o(o));
endmodule
