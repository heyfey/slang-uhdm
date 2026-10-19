// § bitSignedElabVar412
typedef bit signed [3:0] sb_t;
module sub(input bit signed pi, output bit signed [1:0] po, input sb_t pt);
  assign po = {pi, pi};
endmodule
module top();
  typedef bit signed tb_t;
  tb_t a;
  sb_t b;
  bit signed c;
  bit signed [1:0] d;
  sub u(.pi(c), .po(d), .pt(b));
endmodule
