// § defGenCaCommaListSpan283
module dut (input logic [3:0] x, output logic [3:0] a);
  if (1) begin : g
    assign a[1:0] = x[1:0], a[3:2] = x[3:2];
  end
endmodule
