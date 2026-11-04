// § genChildParentAtBirth261
interface bus; logic [31:0] d; logic [15:0] o; modport m(input d, output o); endinterface
module leaf (bus.m b);
  assign b.o = b.d[31:16] ^ b.d[15:0];
endmodule
module mid (bus b);
  if (1) begin : g
    leaf l (.b(b));
  end
endmodule
module top;
  bus b ();
  mid m (.b(b));
endmodule
