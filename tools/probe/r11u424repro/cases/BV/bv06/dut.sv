// § boundSizedLitKept424 (the rp32 rv32_csr_pkg shape)
package p;
  typedef logic [31:0] logic_xlen_t;
  typedef struct packed {
    logic_xlen_t [12'h000:12'h000] res_000_000;
    logic_xlen_t [12'h004:12'h005] res_004_005;
  } csr_map_st;
endpackage
module top import p::*; (input csr_map_st s, output logic o);
  csr_map_st q;
  assign o = s.res_000_000[0][0];
endmodule
