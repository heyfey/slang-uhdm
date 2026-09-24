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
  function automatic logic f(p::w_t [1:0] t, logic r, logic [1:0] i);
    return t[r].f.sat[i];
  endfunction
endpackage
module dut(input logic r, input logic [1:0] i, input p::w_t [1:0] t, output logic o);
  assign o = q::f(t, r, i);
endmodule
