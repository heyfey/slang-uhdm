// § classCovergroupPropSilent402
class c;
  bit [1:0] a, b;
  covergroup g1; coverpoint a; endgroup
  covergroup g2; coverpoint b; endgroup
  function new(); g1 = new; g2 = new; endfunction
endclass
module top;
endmodule
