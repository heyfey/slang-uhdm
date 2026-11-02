// § importCopyTsInstByRole469
// an unpacked-array typedef parameter
package a;
  typedef logic [3:0] arr_t [2];
  parameter arr_t PR = '{4'd1, 4'd2};
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
