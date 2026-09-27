// § tfArgQualOutsideWriter176
package p;
  typedef union packed { logic [7:0] w; logic [1:0][3:0] n; } u_t;
endpackage
module dut(input logic [7:0] i, output logic [3:0] o);
  function automatic logic [3:0] lo(input p::u_t v);
    return v.n[0];
  endfunction
  assign o = lo(p::u_t'(i));
endmodule
