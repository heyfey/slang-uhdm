// § defNetVarNoSlot130v
// case v03: var with an anonymous enum with a base and two declarators
module top(output logic [3:0] o);
  var enum logic [1:0] {A, B} x, y;
  assign o = {x, y};
endmodule
