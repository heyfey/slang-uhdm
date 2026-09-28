// § modGenericClassListed196 § modGenericHandleBare196: a generic class extending a plain module class, a function formal and return of the specialization
module sub ();
  class base;
    int k;
  endclass
  class box #(type E = int) extends base;
    E v;
    function E get(); return v; endfunction
  endclass
  function automatic int f(box #(shortint) x); return 1; endfunction
  box #(byte) b;
endmodule
module top;
  sub v ();
endmodule
