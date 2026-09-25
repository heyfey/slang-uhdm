// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
class C;
  s_t sd [4];
  function void set(int k);
    this.sd[k+1].v = 1'b1;
    sd[k-1].r = 4'h2;
  endfunction
endclass
module dut(output logic o);
  C c = new;
  initial begin c.set(1); o = 1'b0; end
endmodule
