// § taggedUnionElabSpan137
module top ();
  union tagged packed {
    void invalid;
    bit [3:0] b;
  } u;
  initial u = tagged b (4'd1);
endmodule
