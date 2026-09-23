// LAW A: the dropped file-scope innermod carries its own subtree (a ported leaf)
module leaf (output logic l); assign l = 1'b0; endmodule
module innermod (output logic q); leaf u_l (.l(q)); endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic p;
  sub u_s ();
  innermod u_f (.q(p));
  assign o = 32'd0;
endmodule
