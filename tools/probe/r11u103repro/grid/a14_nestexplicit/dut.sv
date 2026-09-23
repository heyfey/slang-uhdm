// LAW A: the nested innermod is EXPLICITLY instantiated in sub (a written instance takes the bare key first)
module innermod (output logic q); assign q = 1'b1; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
  innermod u_i ();
endmodule
module dut (output logic [31:0] o);
  logic p;
  sub u_s ();
  innermod u_f (.q(p));
  assign o = 32'd0;
endmodule
