// § genPathExprSelSpan255 (an interface-port target with an expression select)
interface kif; typedef struct packed { logic [3:0] d; } e_t; e_t [7:0] key; modport m(output key); endinterface
module hmac (kif.m b);
  for (genvar i = 0; i < 8; i++) begin : g
    assign b.key[7-i].d = '0;
  end
endmodule
module top; kif k(); hmac u (.b(k)); endmodule
