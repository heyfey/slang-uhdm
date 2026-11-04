// § procReplCountOwner254 (the count in a case item and a case expression, and in a for-loop bound)
package pk;
  parameter int N = 3;
  parameter int M = 2;
endpackage
module top import pk::*; (input logic [5:0] a, output logic [3:0] o);
  always_comb begin : p_c
    o = '0;
    case (a)
      {N{2'b10}}: o = 4'd1;
      default: o = 4'd2;
    endcase
    for (int i = 0; i < {N{1'b1}}; i++) o = o + 1;
  end
endmodule
