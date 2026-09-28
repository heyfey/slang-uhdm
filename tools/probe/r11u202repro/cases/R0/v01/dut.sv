// § defGenInitRhsKeepsParent200
module v01(input logic [7:0] m, input logic [7:0] n, output logic [7:0] o);
  if (1) begin : g1
    logic [7:0] s = m + n;
    logic [7:0] c = {m[3:0], n[3:0]};
    if (1) begin : g2
      logic [7:0] w = s | c;
    end
  end
  assign o = m;
endmodule
