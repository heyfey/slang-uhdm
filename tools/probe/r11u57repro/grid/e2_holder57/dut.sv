// r11u57 — IS THE HOLDER A GATE FOR THE BURIED CALL?  The two corpus
// witnesses both write the buried call in the PARAMETER PORT LIST, so that
// holder is the one that must move; the module body and a function body are
// asked beside it.
package pk;
  typedef struct packed { logic [2:0] a; } small_t;                 // 3
endpackage
module dut #(
    parameter type TP = logic [1:0],
    localparam int PL = (1 << $bits(TP)),      // PARAMETER-PORT-LIST holder
    localparam type rt_t = TP [PL-1:0]
) (
    input  rt_t  rt_i,
    output logic o
);
  localparam int BL = (1 << $bits(TP)) + 1;    // MODULE-BODY holder
  localparam int CL = (1 << $bits(pk::small_t)); // CONTROL, body holder
  function automatic int f();
    return $bits(TP) + 3;                      // FUNCTION-BODY holder
  endfunction
  localparam int FL = f();
  assign o = ^{rt_i, BL[0], CL[0], FL[0]};
endmodule
