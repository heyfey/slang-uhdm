// § nonReduceOpArgBare201
module sub(input logic [7:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    logic [3:0] t;
    assign t = f(a[i+3:i]) ^ 4'd1;
  end
  assign o = g[1].t;
endmodule
module top(input logic [7:0] a, output logic [3:0] o);
  sub u(.a(a), .o(o));
endmodule
