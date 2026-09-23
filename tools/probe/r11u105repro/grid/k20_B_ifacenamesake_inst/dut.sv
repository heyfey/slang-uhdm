// golden grid: dut INSTANTIATES the interface namesake
interface innermod (); logic [3:0] f; endinterface
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  innermod u_i ();
  assign o = {28'd0, u_i.f};
endmodule
