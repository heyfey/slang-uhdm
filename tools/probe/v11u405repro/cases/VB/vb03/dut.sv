// § blockParamWrittenRhs405
module top();
  function automatic int f(int x);
    begin
      localparam W = 2 * 3;
      return x + W;
    end
  endfunction
  initial $display("%d", f(1));
endmodule
