// break: sub (holding nested innermod) is reached only from a NON-taken generate; late ported namesake top
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut #(parameter bit EN = 0) (output logic [31:0] o);
  if (EN) begin : g
    sub u_s ();
  end
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
