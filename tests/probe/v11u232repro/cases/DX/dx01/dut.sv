// § defAggParamBindsImportClone232
package p;
  typedef struct packed { int unsigned a; bit f; } cfg_t;
  typedef union packed { logic [32:0] w; cfg_t c; } cu_t;
endpackage
// a packed union parameter, header import
module child import p::*; #(parameter cu_t U = '0) (input logic x, output logic y);
  assign y = U.c.f ? x : 1'b0;
endmodule
module top import p::*; (input logic x, output logic y);
  child #(.U(33'h1_0000_0001)) u_c (.x(x), .y(y));
endmodule
