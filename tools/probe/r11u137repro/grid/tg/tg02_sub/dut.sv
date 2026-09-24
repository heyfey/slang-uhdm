// § taggedUnionElabSpan137
module sub ();
  union tagged packed {
    bit [3:0] a;
    bit [3:0] b;
  } u;
  initial u = tagged a (4'd1);
endmodule
module top (); sub s(); endmodule
