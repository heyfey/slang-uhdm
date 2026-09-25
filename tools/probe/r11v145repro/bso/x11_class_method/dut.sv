// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
class C;
  s_t sd [4];
  function logic f(int k);
    return sd[k+1].v;
  endfunction
endclass
module dut(output logic o);
  C c = new;
  initial o = c.f(1);
endmodule
