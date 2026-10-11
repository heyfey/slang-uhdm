// § pkgAliasTdRefNameByParent284
package pk;
  typedef logic [3:0] b_t;
  typedef b_t a_t;
  function automatic a_t g(input a_t x);
    return x;
  endfunction
endpackage
module dut(input logic [3:0] i, output logic [3:0] o);
  assign o = pk::g(i);
endmodule
