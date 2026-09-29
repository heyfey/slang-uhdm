// § genScopeRangeQueryFold216 + § ndaRangeQueryFold216 — an interface with a gen-for query and a net initializer, instantiated twice with different widths
interface bus #(parameter int W = 4) ();
  logic [W-1:0] d;
  logic [7:0] q1;
  wire [7:0] q2 = $high(d);
  for (genvar i = 0; i < 1; i++) begin : g
    assign q1 = $left(d);
  end
endinterface
module dut (output logic [7:0] o1, output logic [7:0] o2);
  bus #(.W(3)) b3 ();
  bus #(.W(6)) b6 ();
  assign o1 = b3.q1 + b3.q2;
  assign o2 = b6.q1 + b6.q2;
endmodule
