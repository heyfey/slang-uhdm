// § pselConnArrPathName261
package gp;
  parameter int BW = 12;
  parameter int LB = 2;
endpackage
interface leafif (input logic [9:0] addr_i);
  logic o;
  assign o = ^addr_i;
endinterface
module core import gp::*; (input logic [15:0] ma, output logic o);
  leafif i_flash (.addr_i(ma[BW-1:LB]));
  assign o = i_flash.o;
endmodule
module bank (input logic [15:0] a, output logic [1:0] o);
  for (genvar b = 0; b < 2; b++) begin : gen_banks
    core i_core (.ma(a), .o(o[b]));
  end
endmodule
module top;
  logic [15:0] a; logic [1:0] o;
  bank u (.a(a), .o(o));
endmodule
