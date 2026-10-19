// § tdAtomRetAliasTwin412
module sub(output int o);
  typedef int i_t;
  function i_t f(); return 5; endfunction
  assign o = f();
endmodule
module top(output int o1, output int o2);
  sub a(o1);
  sub b(o2);
endmodule
