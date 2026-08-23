// r10uvm114 arm F — the SeqDriver import topology: package B wildcard-imports
// package A, and the module wildcard-imports BOTH.  The enum whose base is a
// named vector typedef lives in A.
`define MASK114 32

package bramble114_pkg;
  parameter  int Span = 12;
  typedef bit   [`MASK114-1:0] macmask_t;
  typedef logic [32-1:0]       litmask_t;
  typedef bit   [Span-1:0]     parmask_t;
  typedef bit   [7:0]          plainmask_t;
  typedef enum macmask_t   { MAC_ZERO   = 0 } mac_e;
  typedef enum litmask_t   { LIT_ZERO   = 0 } lit_e;
  typedef enum parmask_t   { PAR_ZERO   = 0 } par_e;
  typedef enum plainmask_t { PLAIN_ZERO = 0 } plain_e;

  class Furze114;
    mac_e held;
    function new(); held = MAC_ZERO; endfunction
  endclass
endpackage

package heather114_pkg;
  import bramble114_pkg::*;

  class Sedge114 extends Furze114;
    function new(); super.new(); endfunction
    function mac_e echo(mac_e arg); return arg; endfunction
  endclass
endpackage

module marram114_top;
  import bramble114_pkg::*;
  import heather114_pkg::*;

  mac_e   sig_mac;
  lit_e   sig_lit;
  par_e   sig_par;
  plain_e sig_plain;

  initial begin
    sig_mac = MAC_ZERO; sig_lit = LIT_ZERO;
    sig_par = PAR_ZERO; sig_plain = PLAIN_ZERO;
  end
endmodule
