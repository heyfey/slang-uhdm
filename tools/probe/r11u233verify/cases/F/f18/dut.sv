// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — package variable initializers (expression grammar outside a subroutine)
package p1;
  int pv = p2::K;
  int pw = p2::K + 1;
  localparam int X = 1;
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
