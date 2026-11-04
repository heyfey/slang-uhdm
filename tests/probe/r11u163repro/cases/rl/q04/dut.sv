// § paramOpCloneRelocatedSpan163
package p;
  typedef struct packed {
    int unsigned n;
    logic [63:0] base;
  } cfg_t;
  localparam cfg_t LIT = '{n: 3, base: 64'h1000};
  function automatic cfg_t mk(int unsigned k);
    return '{n: k, base: 64'h0};
  endfunction
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o_n);
  assign o_n = CFG.n;
endmodule
