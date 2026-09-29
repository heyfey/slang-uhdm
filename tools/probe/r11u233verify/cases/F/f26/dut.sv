// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — dimension bounds of a package typedef and a package localparam packed type (constant grammar outside a subroutine)
package p1;
  typedef logic [p2::K-1:0] v_t;
  localparam logic [p2::K:0] L = '1;
  typedef enum logic [2:0] {A = p2::E1, B} le_t;
  localparam int X = $bits(v_t) + int'(L);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
