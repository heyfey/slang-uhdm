// § modGenericClassListed196 § modGenericHandleBare196: a program home
program sub ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b;
endprogram
module top;
  sub v ();
endmodule
