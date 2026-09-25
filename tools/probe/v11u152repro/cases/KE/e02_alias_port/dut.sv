// § packedElemAliasTypedef152
package lp;
   typedef enum logic [3:0] { On = 4'b1010, Off = 4'b0101 } tx_e;
   typedef tx_e tx_t;
endpackage
module sub(input lp::tx_t [1:0] i, output logic [3:0] o);
  assign o = i[0];
endmodule
module top(output logic [3:0] o);
  lp::tx_t [1:0] w;
  assign w = {lp::On, lp::Off};
  sub u(.i(w), .o(o));
endmodule
