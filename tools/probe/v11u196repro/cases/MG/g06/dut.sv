// § modGenericClassListed196: a generic class declared in a module that is never specialized, beside a used plain class
module sub ();
  class unused #(type E = int);
    E v;
  endclass
  class plain; int k; endclass
  plain p;
endmodule
module top;
  sub v ();
endmodule
