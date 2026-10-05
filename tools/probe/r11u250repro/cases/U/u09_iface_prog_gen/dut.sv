// § modParamKwTdCopy250
typedef shortint us_t;
package p;
  typedef longint pl_t;
endpackage
interface ifc;
  import p::*;
  parameter pl_t A = 5;
  parameter us_t B = 3;
endinterface
program prg;
  parameter us_t C = 1;
endprogram
module top;
  import p::*;
  ifc #(.A(7)) i0();
  prg g0();
  for (genvar k = 0; k < 2; k++) begin : g
    localparam us_t D = k;
  end
endmodule
