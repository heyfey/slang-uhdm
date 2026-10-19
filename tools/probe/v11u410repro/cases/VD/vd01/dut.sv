// § clsMethodDimRefColons410
class C #(parameter N = 4);
  function void f(input int a[N-1:0], input int b[0:N]);
  endfunction
  task t(input int c[N]);
  endtask
endclass
module top; C #(3) c = new; endmodule
