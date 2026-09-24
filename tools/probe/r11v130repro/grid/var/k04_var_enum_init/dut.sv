// § defNetEndOnlyLoc130
package pkg;
  typedef enum logic [3:0] { On = 4'b1010 } E;
endpackage
module top(output int o);
  var enum {A, B, C} x = B;
  var pkg::E [3:0] z = '{4{pkg::On}};
  assign o = x + z;
endmodule
