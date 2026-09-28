// § modGenericClassListedAtDefault200
module sub ();
  class box #(type E = int, int N = 2);
    E v [N];
  endclass
  box #(byte, 3) b;
  box c;
endmodule
program pr;
  class pb #(int W = 1);
    logic [W-1:0] q;
  endclass
  pb #(4) h;
endprogram
module top;
  sub v ();
  pr p ();
endmodule
