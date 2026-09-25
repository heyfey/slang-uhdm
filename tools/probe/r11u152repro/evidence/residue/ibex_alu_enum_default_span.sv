// residue (r11u152, sister ground): the definition param_assign Rhs of a package-qualified enum default spans only `pk::` in golden (ExprEmit emitExpr / tryFoldConst < ParamEmit emitParameters)
package pk;
  typedef enum integer { RNone = 0, RBal = 1 } r_e;
endpackage
module alu #(
  parameter pk::r_e R = pk::RNone
) (output logic o);
  assign o = (R == pk::RBal);
endmodule
module top(output logic o);
  alu u(.o(o));
endmodule
