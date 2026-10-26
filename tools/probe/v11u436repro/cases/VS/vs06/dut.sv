// § clsSpecSurelogOrder436
class C #(parameter p = 2, type T = int);
endclass
module top;
typedef C#(1, real) ct;
ct v;
endmodule
