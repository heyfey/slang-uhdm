// r11v57 B4 — the buried call as an ARGUMENT of a constant function and of
// another system call.  Neither is an `operation`; the emission composes
// differently.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
module dut #(parameter type TP = logic [1:0]) (output logic o);
  function automatic int dbl(input int v); return v * 2; endfunction
  localparam int F1 = dbl($bits(TP));            // user constant function
  localparam int F2 = dbl($bits(pk::req_t));     // CONTROL
  localparam int F3 = $clog2($bits(TP) + 1);     // system call over the call
  localparam int F4 = $clog2($bits(pk::req_t));  // CONTROL
  assign o = ^{F1[0], F2[0], F3[0], F4[0]};
endmodule
