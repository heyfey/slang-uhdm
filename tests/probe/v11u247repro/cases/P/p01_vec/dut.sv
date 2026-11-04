// § pureVirtFormalSignKwTrim247
package p;
  virtual class base;
    pure virtual function void f(logic [3:0] a, reg [7:0] b, bit [2:0] c);
    pure virtual task t(bit [1:0][3:0] d, logic signed [5:0] e);
  endclass
endpackage
module top;
  import p::*;
  base x;
endmodule
