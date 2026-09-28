// § modGenericClassListed196 § modGenericHandleBare196: a specialization as a module function's formal, return and local, and a process local
module sub ();
  class box #(type E = int);
    E v;
  endclass
  function automatic box #(byte) mk(box #(byte) src);
    box #(byte) t;
    t = src;
    return t;
  endfunction
  initial begin
    box #(byte) q;
    q = mk(q);
  end
endmodule
module top;
  sub u ();
endmodule
