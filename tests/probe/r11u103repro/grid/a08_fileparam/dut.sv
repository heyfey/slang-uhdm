// LAW A: the file-scope innermod is PARAMETERIZED and overridden
module innermod #(parameter int W = 2) (output logic [W-1:0] q); assign q = '0; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [4:0] p;
  sub u_s ();
  innermod #(.W(5)) u_f (.q(p));
  assign o = 32'd0;
endmodule
