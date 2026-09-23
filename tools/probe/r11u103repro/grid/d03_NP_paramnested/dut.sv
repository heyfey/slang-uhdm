// LAW B road NP: minted PARAMETERIZED nested passes its parameter to the leaf
module leaf #(parameter int W = 3) (output logic [W-1:0] l); assign l = '0; endmodule
module sub ();
  module innermod #(parameter int P = 4) ();
    logic [P-1:0] r;
    leaf #(.W(P)) u_l (.l(r));
  endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
