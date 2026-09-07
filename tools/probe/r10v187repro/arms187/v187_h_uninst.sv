// v187 arm H -- a package NEVER imported (DEF listing only), a package reached
// only by a QUALIFIED reference, and a fan-out of many parameters on ONE
// typedef.
package ph187;
  typedef int h_i_t;
  parameter h_i_t H0 = 0;
  parameter h_i_t H1 = 1;
  parameter h_i_t H2 = 2;
  parameter h_i_t H3 = 3;
  parameter h_i_t H4 = 4;
  localparam h_i_t H5 = 5;
endpackage
package hq187;
  typedef byte q_by_t;
  parameter q_by_t Q0 = 6;
endpackage
module mh187 ();
  localparam int MH = hq187::Q0;
endmodule
