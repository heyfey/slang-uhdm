// r11u92 n5 -- THE CONTROL LAW B's third face needs: a non-ANSI port with NO
// body re-declaration at all.  Whatever golden writes for THIS net is what a
// port-declaration-only net looks like.
module sub (o, p);
  output [31:0] o;
  output [31:0] p;
  wire [31:0] p = 32'd13;
  assign o = 32'd12;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  sub u_s (.o(o), .p(q));
endmodule
