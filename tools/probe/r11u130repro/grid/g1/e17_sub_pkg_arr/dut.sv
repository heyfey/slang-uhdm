// § defNetEndOnlyLoc130
package pkg;
  typedef enum logic [1:0] { R, G } E;
endpackage
module sub;
  pkg::E [1:0] a;
  pkg::E [2:0] b = '{3{pkg::G}};
  initial a = '{2{pkg::R}};
endmodule
module top;
  sub u();
endmodule
