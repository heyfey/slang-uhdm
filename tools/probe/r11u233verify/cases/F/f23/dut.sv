// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — an inside value range and a case-inside item in a function body
package p1;
  function automatic int f(int a);
    if (a inside {[p2::E1:p2::E3]}) return 1;
    case (a) inside
      [p2::K:p2::K+2]: return 2;
      default: return 0;
    endcase
  endfunction
  localparam int X = f(2);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
