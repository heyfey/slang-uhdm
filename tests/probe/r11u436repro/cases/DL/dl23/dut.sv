// § genClsNoDefRangeSyntax436
class B #(int K);
  function logic [K-1:0] g();
    return 0;
  endfunction
endclass
class C #(int N) extends B #(4);
  function logic [N-1:0] f();
    return 0;
  endfunction
endclass
module top;
endmodule
