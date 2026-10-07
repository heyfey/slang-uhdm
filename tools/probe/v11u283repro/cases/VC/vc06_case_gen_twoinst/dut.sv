// § defGenCaCommaListSpan283
module m #(parameter int K = 0) (input logic [3:0] x, output logic [3:0] a, b);
  case (K)
    0: begin : c0 assign a = x, b = ~x; end
    default: begin : cd assign a = ~x, b = x; end
  endcase
endmodule
module dut (input logic [3:0] x, output logic [3:0] a, b, c, d);
  m #(.K(0)) u0 (.x(x), .a(a), .b(b));
  m #(.K(1)) u1 (.x(x), .a(c), .b(d));
endmodule
