// § modGenericClassListed196 § modGenericHandleBare196: a plain module class extending a specialization of a module generic, and a typedef of a specialization
module sub ();
  class box #(type E = int);
    E v;
  endclass
  class d extends box #(byte);
    int k;
  endclass
  typedef box #(shortint) bt;
  d h;
  bt t;
endmodule
module top;
  sub v ();
endmodule
