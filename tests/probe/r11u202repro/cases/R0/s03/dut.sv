// § tfSigningSpanFollowsCompilePath200
`define RT(t) t
module s03;
  function `RT(integer unsigned) f1(input `RT(bit signed) a);
    return a;
  endfunction
  function
    logic unsigned
    f2(input int
       signed a);
    return a[0];
  endfunction
endmodule
