// r10uvm210 grid arm C — THE CORPUS TOPOLOGY.  SeqDriver's testbench.sv is
// `package adpcm_pkg; import uvm_pkg::*;` and then `module top_tb; import
// uvm_pkg::*; import adpcm_pkg::*;`.  This arm is that exact nesting: an
// IMPORTING PACKAGE and an IMPORTING MODULE over the arm-B chain, so the
// materialized copies can be scored next to the home.
package p210c;
  parameter C_NUMFLAGS   = 17;
  parameter C_EXTRAS     = (1<<C_NUMFLAGS);
  parameter C_START      = C_EXTRAS+1;
  parameter C_SET        = C_START+1;
  parameter C_SETINT     = C_SET;
  parameter C_LIT        = 5;
  parameter C_REFLIT     = C_LIT;
endpackage
package p210c_imp;
  import p210c::*;
endpackage
module m210c;
  import p210c::*;
  import p210c_imp::*;
endmodule
