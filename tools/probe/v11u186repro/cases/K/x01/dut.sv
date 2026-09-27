// § classImportParamOwnRefs183 (an unsized based literal abstains; a localparam; a sized literal)
package s;
  parameter int unsigned A = 'hf00;
  localparam logic [7:0] B = 8'd7;
  parameter string C = "x";
endpackage
package p;
  import s::*;
  class d1;
    int x = A;
    logic [7:0] y = B;
    string z = C;
  endclass
endpackage
module top; endmodule
