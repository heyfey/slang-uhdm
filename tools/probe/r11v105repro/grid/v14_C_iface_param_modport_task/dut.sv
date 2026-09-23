// break: interface namesake with a parameter, modport and a function; instantiated with an override + uninst use as port
interface innermod #(parameter int W = 4) (); logic [W-1:0] f; modport mp (input f); function automatic int g(); return W; endfunction endinterface
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module user (innermod.mp p, output logic [31:0] q); assign q = p.f; endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  innermod #(.W(8)) u_i ();
  user u_u (.p(u_i), .q(o));
endmodule
