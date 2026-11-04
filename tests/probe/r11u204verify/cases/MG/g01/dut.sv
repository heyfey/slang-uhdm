// § modGenericClassListed196 § modGenericHandleBare196: a value-parameter class with a default, the default handle, two value specializations and #() as handles
module sub ();
  class vec #(int W = 4);
    logic [W-1:0] d;
    function int width(); return W; endfunction
  endclass
  vec a;
  vec #() b;
  vec #(8) c;
  vec #(.W(16)) e;
endmodule
module top;
  sub u ();
endmodule
