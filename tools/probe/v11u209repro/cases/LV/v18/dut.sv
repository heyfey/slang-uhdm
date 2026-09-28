// § tfItemInitLocalAtType209: a generate-block paren-less function with a body input and initialized locals
module top(output int r);
  if (1) begin : g
    function automatic int f;
      input int a;
      int t = 3;
      logic [1:0] m = 2'd1;
      return a + t + m;
    endfunction
    assign r = f(4);
  end
endmodule
