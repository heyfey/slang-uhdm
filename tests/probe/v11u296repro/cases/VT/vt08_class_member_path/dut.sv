// § castTsInPathIdxByChain296
package p;
  class C;
    typedef struct packed {logic [31:0] f;} st_t;
    st_t q;
    function logic get(input logic [7:0] k);
      return q.f[3'(k)];
    endfunction
  endclass
endpackage
module dut(output logic o);
  initial begin p::C c; c = new(); o = c.get(8'd1); end
endmodule
