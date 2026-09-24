// break: uninstantiated parameterized interface namesake with a modport, declared after dut
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
interface innermod #(parameter int W = 4) (input logic clk); logic [W-1:0] f; modport mp (input f, input clk); endinterface
