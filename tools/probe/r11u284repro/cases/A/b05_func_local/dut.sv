// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] x);
    pk::a_t t;
    t = x;
    return t;
  endfunction
  assign o = f(i);
endmodule
