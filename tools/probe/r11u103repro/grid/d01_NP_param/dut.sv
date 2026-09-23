// LAW B road NP: minted PORTED nested instantiates a parameterized leaf
module leaf #(parameter int W = 3) (output logic [W-1:0] l); assign l = '0; endmodule
module sub ();
  module innermod (output logic [5:0] r);
    leaf #(.W(6)) u_l (.l(r));
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
