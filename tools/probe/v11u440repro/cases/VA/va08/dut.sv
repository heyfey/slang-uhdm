// § defNetModTdCloneBoundSyntax440
module m (a);
  parameter w = 8;
  typedef logic [w-1:0] t;
  input t a;
  t z;
endmodule
module top; m u(.a(8'h0)); endmodule
