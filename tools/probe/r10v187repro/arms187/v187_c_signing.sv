// v187 arm C -- SIGNING variants of the three minted scalar kinds.
package ps187;
  typedef int unsigned  s_iu_t;
  typedef int signed    s_is_t;
  typedef byte unsigned s_byu_t;
  typedef byte signed   s_bys_t;
  typedef bit signed    s_b1s_t;
  parameter  s_iu_t  S_IU  = 1;
  parameter  s_is_t  S_IS  = -3;
  parameter  s_byu_t S_BYU = 2;
  parameter  s_bys_t S_BYS = -4;
  parameter  s_b1s_t S_B1S = 1'b1;
  localparam s_iu_t  S_LIU = 5;
endpackage
module ms187 ();
  import ps187::*;
  localparam int MS = S_IU + S_BYU;
endmodule
