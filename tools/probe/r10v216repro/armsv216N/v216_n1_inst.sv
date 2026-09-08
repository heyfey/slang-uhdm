// N1 — the SAME exporting interface instantiated 1 time(s).
interface v216_ifn;
  export "DPI-C" function en_two;
  export "DPI-C" function en_one;
  function automatic int plain_n(int x);
    return x + 1;
  endfunction
  function automatic int en_one(int x);
    return x + 2;
  endfunction
  function automatic int en_two(int x);
    return x + 3;
  endfunction
endinterface
module v216_topn;
  v216_ifn u1();
  initial begin
    if (u1.plain_n(1) == 0) $display("x");
  end
endmodule
