// § modGenericClassListed196 § modGenericHandleBare196: a value parameter
module sub ();
  class box #(int W = 4);
    logic [W-1:0] v;
  endclass
  box #(8) b;
endmodule
module top;
  sub v ();
endmodule
