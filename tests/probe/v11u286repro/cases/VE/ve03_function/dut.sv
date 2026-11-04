// § escBlockNameSpanTrailSpace286
module top;
  function automatic int f(int x);
    begin : \fb@1 
      return x;
    end
  endfunction
  int r;
  initial r = f(1);
endmodule
