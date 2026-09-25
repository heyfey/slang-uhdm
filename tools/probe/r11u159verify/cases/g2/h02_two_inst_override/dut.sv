// § concatArrParamDefTs151
module sub #(parameter int S = 0)();
  localparam int A3[0:2] = {1, 2, 3 + S};
  parameter A = A3[2];
  if (A == 5) begin : g
    initial $display("five");
  end
endmodule
module top();
  sub #(.S(2)) u1();
  sub u2();
endmodule
