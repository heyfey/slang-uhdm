// ARM B — THE IN-BODY CONTROL.  The same class, the same declarations, defined
// INSIDE the class body.  Surelog compiles these in the LATER class pass, so
// this arm says what an in-body method's placeholder carries and whether the
// package's DEF listing holds a copy at all.
package p213b;
  class c213b #(type T213 = int, type U213 = int);
    function void fb213(T213 x213);
      T213 locb213;
      locb213 = x213;
    endfunction
    task tb213(output U213 y213);
      U213 loctb213;
      y213 = loctb213;
    endtask
  endclass
endpackage
module top213b;
  initial begin end
endmodule
