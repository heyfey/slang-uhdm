// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a module parameter reading the later package inside a pattern (a module scope: the law declines, control)
package p1;
  localparam int X = 1;
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module m #(parameter p2::e_t P = p2::E1);
endmodule
module dut (output int o);
  assign o = p1::X;
endmodule
