// golden grid control for k19: an uninstantiated file-scope interface, NO nested namesake
interface ifc (); logic [3:0] f; endinterface
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
