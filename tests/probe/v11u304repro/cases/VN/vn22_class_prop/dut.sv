// § hpOpIdxNestedSelByPath304
class C;
  typedef struct packed {logic [7:0] fld;} el_t;
  el_t ea [4];
  int k [2];
  function logic [7:0] rd();
    return ea[k[0] + 1].fld;
  endfunction
endclass
module top (output logic [7:0] o);
  initial begin C c = new; o = c.rd(); end
endmodule
