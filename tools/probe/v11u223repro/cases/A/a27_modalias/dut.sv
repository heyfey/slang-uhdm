// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
endpackage
package q;
  typedef p::UVM_FILE QF;
  class c;
    function void f(QF x);
    endfunction
  endclass
endpackage
module top(input int a, output int o);
  typedef p::UVM_FILE LF;
  function automatic int h(LF z);
    return z;
  endfunction
  assign o = h(a);
endmodule
