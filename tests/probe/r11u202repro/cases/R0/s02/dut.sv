// § tfSigningSpanFollowsCompilePath200
module s02 #(parameter N = 2)(input logic [3:0] i, output logic [3:0] o);
  for (genvar k = 0; k < N; k++) begin : g
    bit unsigned b0;
    logic signed [3:0] l0;
    int unsigned u0;
    byte signed y0;
  end
  function bit signed h(input int unsigned x);
    return x[0];
  endfunction
  assign o = i;
endmodule
