// § implicitNetMintNoFile131
module top(output int o);
  function automatic int f(int x);
    begin : b
      localparam int K = 3;
      return x + K;
    end
  endfunction
  assign o = f(2);
endmodule
