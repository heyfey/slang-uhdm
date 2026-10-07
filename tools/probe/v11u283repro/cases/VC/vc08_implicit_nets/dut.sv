// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] o);
  if (1) begin : g
    wire [3:0] p, q;
    assign p = x, q = ~x;
  end
  assign o = g.p;
endmodule
