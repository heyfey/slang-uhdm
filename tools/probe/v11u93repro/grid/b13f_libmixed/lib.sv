module amod ();
  module innermod (output logic [31:0] ra); assign ra = 32'd1; endmodule
  module pm #(parameter int P = 1) (); wire x; endmodule
  wire [31:0] w;
  innermod u_i (.ra(w));
endmodule
module bmod ();
  module innermod (input logic [7:0] ib); wire y = ib[0]; endmodule
endmodule
