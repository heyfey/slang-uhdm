// LAW A: two late tops, one the namesake, one a plain top instantiating nothing of note
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
module other (output logic p); assign p = 1'b1; endmodule
