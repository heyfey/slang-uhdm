// § delayParenInnerExprSpan292
module top;
  parameter time T1 = 1ns;
  localparam int K = 3;
  int x;
  task automatic a(input int n);
    #(n) x = 1;
    #( n + K ) x = 2;
    #( T1 ) x = 3;
    #(/*z*/n) x = 4;
    x = #( n ) 5;
  endtask
  function automatic int f(int n); return n; endfunction
  initial begin
    #( f(2) ) x = 6;
    #( K > 2 ? 1 : 2 ) x = 7;
    #((K)) x = 8;
    #( {K} ) x = 9;
  end
endmodule
