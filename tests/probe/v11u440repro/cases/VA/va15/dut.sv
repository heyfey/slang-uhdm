// § defNetModTdCloneBoundSyntax440
program pr #(parameter w = 8);
  typedef logic [w-1:0] t;
  t z;
endprogram
module top; pr u(); endmodule
