// § clsMethodDimRefColons410
module top;
  localparam N = 3;
  function automatic void f(input int a[N]);
  endfunction
  class C;
    function void g(input int b[N]);
    endfunction
  endclass
endmodule
