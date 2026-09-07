// v187 arm D -- NAMES, CASE, NUMBERS and DECLARATION ORDER varied: the arm
// that tests rather than agrees.
package po187;
  typedef int A;
  parameter A O_1 = 1;
  typedef int a;
  localparam a O_2 = 2;
  typedef byte Z9_t;
  parameter Z9_t O_3 = 3;
  typedef bit q;
  parameter q O_4 = 1'b0;
  typedef int zzz_very_long_typedef_name_187;
  parameter zzz_very_long_typedef_name_187 O_5 = 5;
  typedef int O_6;
  parameter O_6 O_7 = 7;
  parameter A O_8 = 8;
  typedef byte A2;
  localparam A2 O_9 = 9;
endpackage
module mo187 ();
  import po187::*;
  localparam int MO = O_1 + O_3 + O_5 + O_7 + O_8;
endmodule
