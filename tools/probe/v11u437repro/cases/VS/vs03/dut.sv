// § newLhsVarSelNameSpan437
class C; int v; endclass
module top;
C c[2][3];
initial begin
  c[1]
   [2] = new;
end
endmodule
