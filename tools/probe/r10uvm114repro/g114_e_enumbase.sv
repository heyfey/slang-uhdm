// r10uvm114 arm E — an ENUM whose BASE is a NAMED VECTOR TYPEDEF, in a package
// (both views) and materialized into a module by a wildcard import.  This is
// the SeqDriver/MiniAmiq shape: `typedef bit [`W-1:0] uvm_reg_cvr_t;` then
// `typedef enum uvm_reg_cvr_t {...} uvm_coverage_model_e;`.
`define MASK114 32

package thistle114_pkg;
  parameter  int Span = 12;
  localparam int Lift = 6;

  typedef bit   [`MASK114-1:0]   macmask_t;   // macro literal - 1
  typedef logic [32-1:0]         litmask_t;   // written literal - 1
  typedef bit   [Span-1:0]       parmask_t;   // param - 1
  typedef logic [Span*2-1:0]     mulmask_t;   // param * 2 - 1
  typedef bit   [Span+1:2]       addmask_t;   // param + 1, right = 2
  typedef logic [$clog2(Span)-1:0] clgmask_t; // sys call - 1
  typedef bit   [Lift+Span-1:0]  summask_t;   // three-term
  typedef bit   [7:0]            plainmask_t; // literal control

  typedef enum macmask_t   { MAC_ZERO   = 0 } mac_e;
  typedef enum litmask_t   { LIT_ZERO   = 0 } lit_e;
  typedef enum parmask_t   { PAR_ZERO   = 0 } par_e;
  typedef enum mulmask_t   { MUL_ZERO   = 0 } mul_e;
  typedef enum addmask_t   { ADD_ZERO   = 0 } add_e;
  typedef enum clgmask_t   { CLG_ZERO   = 0 } clg_e;
  typedef enum summask_t   { SUM_ZERO   = 0 } sum_e;
  typedef enum plainmask_t { PLAIN_ZERO = 0 } plain_e;
endpackage

module wren114_top;
  import thistle114_pkg::*;
  mac_e   sig_mac;
  lit_e   sig_lit;
  par_e   sig_par;
  mul_e   sig_mul;
  add_e   sig_add;
  clg_e   sig_clg;
  sum_e   sig_sum;
  plain_e sig_plain;

  // a MODULE-LOCAL twin of the same shape: the control
  localparam int Reach = 12;
  typedef bit  [32-1:0]    loclit_t;
  typedef bit  [Reach-1:0] locpar_t;
  typedef enum loclit_t { LOC_LIT_ZERO = 0 } loclit_e;
  typedef enum locpar_t { LOC_PAR_ZERO = 0 } locpar_e;
  loclit_e sig_loclit;
  locpar_e sig_locpar;

  initial begin
    sig_mac = MAC_ZERO; sig_lit = LIT_ZERO; sig_par = PAR_ZERO;
    sig_mul = MUL_ZERO; sig_add = ADD_ZERO; sig_clg = CLG_ZERO;
    sig_sum = SUM_ZERO; sig_plain = PLAIN_ZERO;
    sig_loclit = LOC_LIT_ZERO; sig_locpar = LOC_PAR_ZERO;
  end
endmodule
