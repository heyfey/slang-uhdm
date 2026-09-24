// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
    logic [1:0] k;
  } w_t;
endpackage
class C;
  p::e_t s;
  function logic g(logic [1:0] i);
    return s.sat[i];
  endfunction
endclass
module dut(output logic o);
  initial begin
    C c = new;
    o = c.g(2'd1);
  end
endmodule
