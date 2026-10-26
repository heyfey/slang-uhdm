// § clsSpecSurelogOrder436
class C #(parameter p = 2, type T = int);
endclass
module top;
function void f();
C#(1, real) v;
endfunction
endmodule
