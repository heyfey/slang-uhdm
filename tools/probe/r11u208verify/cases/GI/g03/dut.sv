// § genVarInitOuterRefUnbound202 § defGenInitRhsKeepsParent200
module g03(input logic [7:0] q, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] x); return ~x; endfunction
  if (1) begin : g
    logic [7:0] a = f(q);
    logic [7:0] b = $clog2(q);
    logic [7:0] c = f(q) + 8'd1;
    logic [7:0] d = q[3] ? q : 8'h0;
  end
  assign o = g.a ^ g.b ^ g.c ^ g.d;
endmodule
