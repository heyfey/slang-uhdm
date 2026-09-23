// LAW C: the interface namesake is instantiated and passed to a module's interface port
interface innermod (); logic [3:0] f; modport mp (input f); endinterface
module user (innermod.mp bus, output logic [3:0] q); assign q = bus.f; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [3:0] q;
  sub u_s ();
  innermod u_i ();
  user u_u (.bus(u_i), .q(q));
  assign o = {28'd0, q};
endmodule
