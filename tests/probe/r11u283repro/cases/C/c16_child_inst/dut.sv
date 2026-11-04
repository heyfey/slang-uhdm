// § defGenCaCommaListSpan283
module sub (input logic [3:0] x, output logic [3:0] a, b);
  if (1) begin : g
    assign a = x, b = ~x;
  end
endmodule
module dut (input logic [3:0] x, output logic [3:0] a, b, c, d);
  sub u1 (.x(x), .a(a), .b(b));
  sub u2 (.x(~x), .a(c), .b(d));
endmodule
