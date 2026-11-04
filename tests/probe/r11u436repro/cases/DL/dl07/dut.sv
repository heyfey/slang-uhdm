// § genClsNoDefRangeSyntax436
class C #(int N);
  task t(input bit [N:0] a, output logic [2*N-1:0] b);
    b = a;
  endtask
endclass
module top;
endmodule
