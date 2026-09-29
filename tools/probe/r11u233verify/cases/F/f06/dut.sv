// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a case item expression in a function body
package p1;
  function automatic int f(int a);
    case (a)
      p2::K: return 1;
      default: return 0;
    endcase
  endfunction
  localparam int X = f(4);
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
