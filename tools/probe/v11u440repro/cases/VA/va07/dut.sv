// § defNetModTdCloneBoundSyntax440
interface ifc #(parameter w = 8);
  typedef logic [w-1:0] t;
  t z;
endinterface
module top; ifc u(); endmodule
