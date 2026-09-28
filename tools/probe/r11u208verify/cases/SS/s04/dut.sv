// § tfSigningSpanFollowsCompilePath200
module s04 #(parameter N = 2) (input logic [7:0] a, output logic [15:0] y);
  for (genvar i = 0; i < N; i++) begin : g
    function automatic shortint signed f(input byte unsigned b, input int unsigned k);
      return b + k;
    endfunction
    int unsigned gv;
    logic [15:0] r;
    assign r = f(a, i);
  end
  if (N > 1) begin : h
    function automatic bit unsigned [7:0] q(input longint signed l);
      return l[7:0];
    endfunction
  end
  assign y = g[0].r ^ g[1].r;
endmodule
