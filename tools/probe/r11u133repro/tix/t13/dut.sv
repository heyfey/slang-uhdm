// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
  } w_t;
endpackage
module dut(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  function automatic logic get(input logic [1:0] rr, input logic [1:0] ii);
    return tbl[rr].sat[ii];
  endfunction
  assign tbl = flat;
  assign o = get(r, i);
endmodule
