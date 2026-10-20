// § clsTdArgAliasTwin414
interface ifc;
  typedef int i_t;
  function automatic int f(i_t a);
    return a;
  endfunction
endinterface
module top;
  ifc i();
endmodule
