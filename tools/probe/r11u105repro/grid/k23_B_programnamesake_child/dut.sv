// LAW B: the program namesake instantiates nothing but the nested module sits under a top outer (no dut)
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
program innermod (input logic c); int f; initial f = c; endprogram
