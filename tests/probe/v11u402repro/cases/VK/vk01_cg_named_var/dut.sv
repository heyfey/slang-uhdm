// § classCovergroupPropSilent402
class c;
  bit [3:0] a;
  covergroup cg;
    coverpoint a;
  endgroup
  function new();
    cg = new;
  endfunction
endclass
module top;
endmodule
