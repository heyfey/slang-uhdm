// r10uvm187 arm D — every SCALAR typedef kind in one package, so the arm sees
// the kinds the law DECLINES as well as the three it mints.
package dk_pkg;
  typedef int      d_int;
  typedef byte     d_byte;
  typedef bit      d_bit;
  typedef shortint d_sh;
  typedef longint  d_lo;
  typedef integer  d_ig;
  typedef logic    d_lg;
  typedef real     d_re;
  typedef time     d_ti;
  parameter  d_int  D_INT = 1;
  localparam d_int  D_INTL = 2;
  parameter  d_byte D_BYTE = 3;
  parameter  d_bit  D_BIT = 1'b1;
  parameter  d_sh   D_SH = 4;
  parameter  d_lo   D_LO = 5;
  parameter  d_ig   D_IG = 6;
  parameter  d_lg   D_LG = 1'b0;
  parameter  d_re   D_RE = 1.25;
  parameter  d_ti   D_TI = 7;
endpackage
