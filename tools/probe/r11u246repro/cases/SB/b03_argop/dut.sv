// § streamBraceInMacroBody246
`include "defs.svh"
package p;
  typedef enum {A, B, C} cmd_e;
  class packer_c;
    bit big_endian;
    bit [63:0] m_bits;
    int count;
  endclass
  class c;
    cmd_e m_command;
    function void do_unpack(packer_c packer);
      `UNPACK_ENUMN (m_command, 32, cmd_e)
    endfunction
  endclass
endpackage
module top;
endmodule
