// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — the function's return type range
package p1;
  function automatic logic [p2::K-1:0] f();
    return '1;
  endfunction
  localparam int X = int'(f());
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
