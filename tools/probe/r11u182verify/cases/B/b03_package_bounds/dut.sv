// § boundLitWrittenDigits172
package p;
  parameter logic [015:00] P = 5;
  typedef logic [0_7:0] b_t;
  typedef struct packed {
    logic [003:0] a;
    b_t           b;
  } s_t;
  function automatic logic [03:0] f(logic [07:0] x);
    return x[3:0];
  endfunction
endpackage
module dut import p::*; (input s_t i, output logic [3:0] o, output b_t q);
  assign o = f(i.b) ^ i.a;
  assign q = P[7:0];
endmodule
