// LAW A x road F: the file-scope innermod is instantiated only inside orphan, which only a NON-TAKEN generate reaches
module innermod (output logic q); assign q = 1'b1; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module orphan (); wire p; innermod u_f (.q(p)); endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  if (0) begin : g
    orphan u_o ();
  end
  assign o = 32'd0;
endmodule
