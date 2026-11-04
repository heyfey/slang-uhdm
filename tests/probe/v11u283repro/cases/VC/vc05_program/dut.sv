// § defGenCaCommaListSpan283
program prg (input logic [3:0] x, output logic [3:0] a, b);
  if (1) begin : g
    assign a = x, b = ~x;
  end
endprogram
module dut (input logic [3:0] x, output logic [3:0] a, b);
  prg u_p (.x(x), .a(a), .b(b));
endmodule
