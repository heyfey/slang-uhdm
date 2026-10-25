// § impNetEnumSlotEnd432
package A;
enum bit {Q0, Q1} X;
endpackage
import A::*;
module top(output o);
  assign o = (X == Q1);
endmodule
