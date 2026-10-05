// § cloneFormalTsParented253 (output, inout and ref formals with a parameter range)
package p;
  parameter W = 8;
  task automatic t(input logic [W:0] a, output logic [W:0] o, inout bit [W-1:0] io, ref logic [3:0] r);
    o = a; io = '0; r = '1;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
