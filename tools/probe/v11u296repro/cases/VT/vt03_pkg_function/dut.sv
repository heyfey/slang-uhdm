// § castTsInPathIdxByChain296
package p;
  typedef struct packed {logic [31:0] f;} st_t;
  st_t q;
  function automatic logic fn(input logic [3:0] kk);
    return q.f[3'(kk)];
  endfunction
endpackage
module dut(output logic o);
  assign o = p::fn(4'd2);
endmodule
