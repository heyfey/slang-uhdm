// § defGenConnSelAtIndex416
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top #(parameter P = 1) (input logic [3:0] x, y, output logic z);
  if (P) begin : g
    sub u (.a({x[1], y[P+1]}), .o(z));
  end
endmodule
