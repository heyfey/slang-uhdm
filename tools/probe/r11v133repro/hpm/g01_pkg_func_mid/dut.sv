// § hpBaseSelMidMemberBare133
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
  function automatic logic f(p::w_t [1:0] t, logic r);
    return t[r].f.valid;
  endfunction
endpackage
module dut(input logic r, input p::w_t [1:0] t, output logic o);
  assign o = q::f(t, r);
endmodule
