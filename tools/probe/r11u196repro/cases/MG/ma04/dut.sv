// § modGenericClassListed196 § modGenericHandleBare196: the bare generic name (default specialization)
module sub ();
  class box #(type E = int);
    E v;
  endclass
  box b;
endmodule
module top;
  sub v ();
endmodule
