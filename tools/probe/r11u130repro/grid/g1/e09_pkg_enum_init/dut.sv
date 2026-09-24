// § defNetEndOnlyLoc130
package pkg;
  typedef enum logic [3:0] { On = 4'b1010 } E;
endpackage
module top(output int o);
  pkg::E [3:0] x = '{4{pkg::On}};
  assign o = x;
endmodule
