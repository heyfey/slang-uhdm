// § unitTaskNotListed408
function automatic int f1(int a); return a; endfunction
task automatic t1(output int o); o = 1; endtask
function automatic void f2(); endfunction
task automatic t2; endtask
module top;
  logic [3:0] a;
  assign a = 4'(f1(2));
endmodule
