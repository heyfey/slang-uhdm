// LAW C: the uninstantiated interface namesake has a port and a modport
interface innermod (input logic clk); logic [3:0] f; modport mp (input f, input clk); endinterface
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
