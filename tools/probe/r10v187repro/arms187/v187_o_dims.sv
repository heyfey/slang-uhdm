// v187 arm O -- packed dims WRITTEN on a scalar typedef name, plus interface
// and program homes the law does not claim.
package po2187;
  typedef bit  o_b1_t;
  typedef int  o_i_t;
  typedef byte o_by_t;
  parameter o_b1_t [3:0] O_BD = 4'h5;
  parameter o_i_t        O_I  = 1;
  parameter o_by_t       O_BY = 2;
endpackage
interface oi187 ();
  typedef int oi_i_t;
  parameter  oi_i_t OI_P = 3;
  localparam oi_i_t OI_L = 4;
endinterface
program op187 ();
  typedef int op_i_t;
  parameter op_i_t OP_P = 5;
endprogram
module mo187 ();
  import po2187::*;
  oi187 u_if ();
  localparam int MO = O_I + O_BY;
endmodule
