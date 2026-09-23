// golden grid: a file-scope INTERFACE innermod (uninstantiated) beside a nested module innermod
interface innermod (); logic [3:0] f; endinterface
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
