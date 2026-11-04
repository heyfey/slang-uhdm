// § newLhsVarSelNameSpan437
class C; int v; endclass
module top;
if (1) begin : g
  C c[2][2];
  initial c[1][1] = new;
end
endmodule
