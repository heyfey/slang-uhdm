// § cloneFormalTsParented253
package p;
  parameter W = 8;
  task automatic t(input logic [W:0] a, output logic [W:0] b);
    b = a;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
