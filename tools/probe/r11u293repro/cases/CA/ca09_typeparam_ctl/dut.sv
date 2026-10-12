// § defNetClassArrTsDimEnd293
// CONTROL: a type parameter defaulting to the class: no move.
package pk;
  class C;
    int idx;
  endclass
endpackage
module m #(parameter type T = pk::C);
  T a [];
endmodule
module top;
  m u ();
endmodule
