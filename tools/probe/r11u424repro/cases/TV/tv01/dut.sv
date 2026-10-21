// § tpVarInitSizedByDefault424 (pass 421 residue rt01)
module ma #(parameter type p2 = shortint) (input logic i);
  p2 j = 0;
endmodule
module top; logic i; ma #(.p2(int)) u1(i); endmodule
