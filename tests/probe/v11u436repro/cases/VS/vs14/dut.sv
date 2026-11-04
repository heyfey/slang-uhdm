// § clsSpecSurelogOrder436
class C #(parameter p = 2, type T = int);
endclass
module top;
C#(1, real) v;
C#(1, real) w;
C#(.p(3)) x;
endmodule
