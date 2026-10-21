// § derivedNestedBareKey422v
// a base in a module with derived classes in the same module, and a nested class
module top;
  class B; endclass
  class Y extends B; endclass
  class X extends B;
    class N extends B; endclass
  endclass
  X x = new; Y y = new;
endmodule
