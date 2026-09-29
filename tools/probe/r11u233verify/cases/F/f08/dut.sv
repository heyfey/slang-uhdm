// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — event controls in a package task: @p2::ev and @(p2::ev)
package p1;
  task automatic t(output int r);
    @p2::ev r = 1;
    @(p2::ev) r = 2;
  endtask
  localparam int X = 1;
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
  event ev;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
