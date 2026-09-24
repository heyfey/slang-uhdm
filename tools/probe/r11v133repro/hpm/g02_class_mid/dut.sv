// § hpBaseSelMidMemberBare133
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
  p::w_t t [2];
  function logic g(int r);
    return t[r].f.valid;
  endfunction
endclass
module dut(output logic o);
  initial begin
    C c = new;
    o = c.g(1);
  end
endmodule
