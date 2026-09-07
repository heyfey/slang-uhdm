// r10uvm187 arm C — HOMES the law does not claim: a module's OWN scalar
// typedef, a generate-scope localparam, a class-scope localparam, and a
// wildcard-imported package typedef named bare in a module.
package hc_pkg;
  typedef int hc_i_t;
  typedef bit [7:0] hc_b_t;
endpackage
module hc_m ();
  typedef int hm_i_t;
  parameter  hm_i_t HM_P = 11;
  localparam hm_i_t HM_L = 12;
  if (1) begin : hg
    localparam hm_i_t HG_L = 13;
  end
  class HC;
    localparam hm_i_t HC_L = 14;
  endclass
endmodule
module hc_mi ();
  import hc_pkg::*;
  parameter hc_i_t HMI_P = 15;
  parameter hc_b_t HMI_B = 8'h16;
endmodule
module hc_top ();
  hc_m u0 ();
  hc_mi u1 ();
endmodule
