// § taggedUnionElabSpan137
// case tu03: a tagged packed signed union
module top();
  union tagged packed signed {
    bit [5:0] a;
    bit [5:0] b;
  } su;
  initial su = tagged a (6'd9);
endmodule
