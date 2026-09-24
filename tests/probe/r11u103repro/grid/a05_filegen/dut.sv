// LAW A: the file-scope instantiation sits in a TAKEN generate block
module innermod (); wire [31:0] f = 32'd9; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  if (1) begin : g
    innermod u_f ();
  end
  assign o = 32'd0;
endmodule
