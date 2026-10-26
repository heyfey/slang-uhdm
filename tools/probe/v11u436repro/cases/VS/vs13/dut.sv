// § clsSpecSurelogOrder436
class C #(parameter p = 2, type T = int);
endclass
module top;
generate if (1) begin : g
C#(1, real) v;
end endgenerate
endmodule
