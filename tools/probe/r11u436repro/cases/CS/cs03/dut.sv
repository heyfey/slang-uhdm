// § clsSpecSurelogOrder436
class C #(type T = int, parameter p = 2);
endclass
module top;
C#(.T(real)) v;
endmodule
