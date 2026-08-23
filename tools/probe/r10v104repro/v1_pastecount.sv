// v104 arm V1 - paste COUNT 0..4 inside one stringification, plus a 5th.
`define VN abc
`define VA 1
`define VB 2
`define VC 3
`define VD 4
`define P0 `"`VN-`VA-`VB-`VC-`VD`"
`define P1 `"`VN``-```VA`"
`define P2 `"`VN``-```VA``.```VB`"
`define P3 `"`VN``-```VA``.```VB``:```VC`"
`define P4 `"`VN``-```VA``.```VB``:```VC``/```VD`"
package v1_pk;
  parameter string q0 = `P0;
  parameter string q1 = `P1;
  parameter string q2 = `P2;
  parameter string q3 = `P3;
  parameter string q4 = `P4;
endpackage
module v1_top; endmodule
