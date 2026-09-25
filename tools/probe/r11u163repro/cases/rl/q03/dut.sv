// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed {
    int unsigned n;
    logic [63:0] base;
  } cfg_t;
  localparam cfg_t LIT = '{n: 3, base: 64'h1000};
  function automatic logic chk(cfg_t C);
    return C.n != 0;
  endfunction
endpackage
module dut import p::*; #(parameter cfg_t CFG = LIT) (output logic [31:0] o_n, output logic o_f);
  assign o_n = CFG.n;
  assign o_f = chk(CFG);
endmodule
