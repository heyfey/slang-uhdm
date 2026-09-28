// § modGenericClassListed196 § classPropElemClassTsAtName196: arrays of a module-local parameterized class as properties of a module class and as module variables
module sub ();
  class box #(type E = int, int N = 2);
    E v [N];
  endclass
  class holder;
    box#(byte, 3) q[$];
    box#(int) fx[2];
    box#(.E(bit)) aa[string];
  endclass
  box#(shortint) mv[4];
  holder h;
endmodule
module top;
  sub u ();
endmodule
