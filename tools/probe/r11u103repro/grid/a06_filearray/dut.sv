// LAW A: the file-scope instantiation is an instance ARRAY
module innermod (output logic q); assign q = 1'b1; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [1:0] p;
  sub u_s ();
  innermod u_f [1:0] (.q(p));
  assign o = 32'd0;
endmodule
