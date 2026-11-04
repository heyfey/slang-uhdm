// § taggedUnionElabSpan137
module top ();
  union packed {
    bit [3:0] a;
    bit [3:0] b;
  } u;
  initial u.a = 4'd1;
endmodule
