// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) ();
endmodule
module mid #(parameter logic [1:0][3:0] P = '0) ();
  sub #(.P(P)) s();
endmodule
module top ();
  mid #(.P(8'h5a)) m();
endmodule
