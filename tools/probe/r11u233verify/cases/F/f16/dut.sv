// § fwdPkgRefClassScopeSpan227 § fwdPkgRefConstSlotWhole227v — a streaming slice size in a function body
package p1;
  function automatic logic [7:0] f(logic [7:0] x);
    return {<< p2::K {x}};
  endfunction
  localparam int X = int'(f(8'h1));
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2, E3, E4} e_t;
  localparam int K = 4;
  localparam logic [7:0] W = 8'hA5;
endpackage
module dut (output int o);
  assign o = p1::X;
endmodule
