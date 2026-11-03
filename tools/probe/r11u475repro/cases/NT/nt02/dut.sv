// § elabRhsSharesDefParamChain475
// a generate-nested child and an instance array of a child reading PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
module top(output logic [3:0] y, output logic [3:0] z [2]);
  if (1) begin : g
    sub u(y);
  end
  sub arr[2] (z);
endmodule
