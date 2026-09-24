// LAW A control: the outer is reached only through a non-taken generate; the late top namesake took the key first
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  if (0) begin : g
    sub u_s ();
  end
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
