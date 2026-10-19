// § parenCastNameUnsupTs410
module top #(parameter W = 4) (input logic [7:0] x, output logic [7:0] y);
  if (W > 1) begin : g
    function automatic logic [7:0] f(input logic [7:0] a);
      return (W)'(a);
    endfunction
    always_comb y = f(x) + (W)'(x[3:0]);
  end
endmodule
