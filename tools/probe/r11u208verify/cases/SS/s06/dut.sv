// § tfSigningSpanFollowsCompilePath200
module s06(input logic [7:0] a, output logic [15:0] y);
  function automatic int unsigned f(input int unsigned k, input shortint signed s);
    return k + s;
  endfunction
  function automatic logic signed [3:0] g(input logic unsigned [3:0] z, input bit signed w);
    return z + w;
  endfunction
  assign y = f(a, 16'sd2) + g(a[3:0], a[0]);
endmodule
