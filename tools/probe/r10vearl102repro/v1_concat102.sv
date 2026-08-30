// v1_concat102 -- CONCAT-init unpacked-array parameters (the unpArrConcatTs9
// trigger of the very same call site the law's flag wraps), package home vs
// module home, RANGE-form `<param> - <literal>` bound.
package v1p102;
  parameter int PN = 3;
  parameter int PCAT [0:PN-1] = {1, 2, 3};       // package + concat + range form
  parameter int PPAT [0:PN-1] = '{1, 2, 3};      // package + pattern (the law's own shape)
  localparam int PLCAT [0:PN-1] = {4, 5, 6};     // package localparam + concat
endpackage

module v1sub102;
  import v1p102::*;
  localparam int MN = 3;
  localparam int MCAT [0:MN-1] = {7, 8, 9};      // module + concat  (must NOT fold)
  localparam int MPAT [0:MN-1] = '{7, 8, 9};     // module + pattern (must NOT fold)
  int touch1 = PCAT[0] + PPAT[0] + PLCAT[0] + MCAT[0] + MPAT[0];
endmodule

module v1_concat102;
  v1sub102 u_a();
endmodule
