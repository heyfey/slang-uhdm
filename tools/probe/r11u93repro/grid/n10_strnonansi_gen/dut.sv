// r11u92 n10 -- a non-ANSI port net re-declared with a strength, beside a
// GENERATE block that declares one of its own.
module sub (o, p);
  output [31:0] o;
  output [31:0] p;
  wire (strong1, weak0) [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
  generate
    if (1) begin : g
      wire (strong1, weak0) [31:0] w_gen = 32'd14;
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  sub u_s (.o(o), .p(q));
endmodule
