// § taggedUnionElabSpan137
// case tu02: a tagged packed union declared in a generate block
module top();
  if (1) begin : g
    union tagged packed {
      bit [3:0] p;
      bit [3:0] q;
    } u2;
    initial u2 = tagged p (4'd2);
  end
endmodule
