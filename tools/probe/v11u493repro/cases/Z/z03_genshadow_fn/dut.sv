// § enumCastChainKeepsInnerCast493
module top(input logic [15:0] a, output logic [15:0] w);
  typedef logic [7:0] t_t;
  if (1) begin : g
    typedef logic [15:0] t_t;
    function automatic logic [15:0] f();
      return 16'(t_t'(a));
    endfunction
    assign w = f();
  end
endmodule
