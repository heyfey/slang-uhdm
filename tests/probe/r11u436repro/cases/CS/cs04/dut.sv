// § clsSpecSurelogOrder436
class C #(parameter p = 2, type T = int);
endclass
module top;
C#(.p(2), .T(real)) v;
endmodule
