// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] o);
  if (1) begin : g
    logic [3:0] l1, l2;
    assign l1 = x, l2 = ~x;
    assign o = l1 & l2;
  end
endmodule
