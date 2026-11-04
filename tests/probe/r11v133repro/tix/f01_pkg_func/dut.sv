// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
    logic [1:0] k;
  } w_t;
endpackage
package q;
  function automatic logic f(p::e_t s, logic [1:0] i);
    return s.sat[i];
  endfunction
endpackage
module dut(input logic [1:0] i, input p::e_t s, output logic o);
  assign o = q::f(s, i);
endmodule
