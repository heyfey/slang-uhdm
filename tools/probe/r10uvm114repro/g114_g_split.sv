// r10uvm114 arm G — the two halves of arm F, separated: gorse114 (two packages,
// NO class) and hazel114 (one package WITH a class), each with its own module.
`define MASK114 32

package gorse114_a_pkg;
  typedef bit [`MASK114-1:0] gmacmask_t;
  typedef enum gmacmask_t { G_MAC_ZERO = 0 } gmac_e;
endpackage

package gorse114_b_pkg;
  import gorse114_a_pkg::*;
  parameter int GorseSpan = 4;
endpackage

module gorse114_top;
  import gorse114_a_pkg::*;
  import gorse114_b_pkg::*;
  gmac_e sig_gmac;
  initial sig_gmac = G_MAC_ZERO;
endmodule

package hazel114_pkg;
  typedef bit [`MASK114-1:0] hmacmask_t;
  typedef enum hmacmask_t { H_MAC_ZERO = 0 } hmac_e;
  class Nettle114;
    hmac_e held;
    function new(); held = H_MAC_ZERO; endfunction
  endclass
endpackage

module hazel114_top;
  import hazel114_pkg::*;
  hmac_e sig_hmac;
  initial sig_hmac = H_MAC_ZERO;
endmodule
