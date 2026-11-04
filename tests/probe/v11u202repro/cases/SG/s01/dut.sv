// § tfSigningSpanFollowsCompilePath200
module s01;
  function automatic logic signed [7:0] f1(input logic signed [3:0] a, input bit unsigned [2:0] b);
    return a + b;
  endfunction
  function automatic byte unsigned f2(input byte unsigned a, output int unsigned o);
    o = a; return a;
  endfunction
  task automatic t1(input shortint signed a, ref int unsigned r);
    r = a;
  endtask
  function automatic reg unsigned f3(input reg signed a);
    return a;
  endfunction
endmodule
