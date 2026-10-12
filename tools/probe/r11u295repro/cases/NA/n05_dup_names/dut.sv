// § nestedModArrayScopedName295
module amod ();
  module innermod (); wire ra; endmodule
endmodule
module bmod (output logic [1:0] o);
  module innermod (output logic rb); assign rb = 1'b1; endmodule
  innermod u_i [1:0] (.rb(o));
endmodule
module dut (output logic [1:0] o);
  amod u_a ();
  bmod u_b (.o(o));
endmodule
