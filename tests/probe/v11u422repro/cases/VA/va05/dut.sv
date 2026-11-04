// § arrayBcastConcatBound422
// a concatenation over a module input, a module wire and a bit-select of a vector
module child(input a, output b);
  assign b = a;
endmodule
module top(input p, input [3:0] v, output [3:0] o);
  wire w = ~p;
  child c[3:0] (.a({p, w, v[2], v[0]}), .b(o));
endmodule
