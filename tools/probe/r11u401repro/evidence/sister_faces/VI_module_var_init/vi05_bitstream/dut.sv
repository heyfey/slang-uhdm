// sister-ground face (no law of this pass; reported in README)
module top();
  struct packed {logic [7:0] a; logic [7:0] b; logic [15:0] c;} s;
  integer a = integer'(s);
endmodule
