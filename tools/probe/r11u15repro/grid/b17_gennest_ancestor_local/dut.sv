module top(input logic [31:0] a, output logic [31:0] o);
  if (1) begin : g1
    logic [31:0] oloc;
    if (1) begin : g2
      logic [31:0] iloc;
      assign oloc = a;
      assign iloc = oloc;
    end
  end
  assign o = a;
endmodule
