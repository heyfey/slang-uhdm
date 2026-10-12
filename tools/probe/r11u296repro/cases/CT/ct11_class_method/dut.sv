// § castTsInPathIdxByChain296
package pc;
  typedef struct packed {logic [31:0] f;} s_t;
  class c;
    s_t q;
    function logic g(input logic [3:0] kk); return q.f[{1'b1, 2'(kk)}]; endfunction
  endclass
endpackage
module dut(output logic o);
  typedef struct packed {logic [31:0] f;} st_t;
  typedef logic [1:0] t2_t;
  st_t q;
  logic [3:0] k;
  logic y1;
  always_comb y1 = 1'b0;
  assign o = y1;
endmodule
