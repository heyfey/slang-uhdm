// break: the nested namesake sits TWO levels deep (sub::mid::innermod); late file-scope top innermod
module sub ();
  module mid ();
    module innermod (); wire [7:0] n = 8'd1; endmodule
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
