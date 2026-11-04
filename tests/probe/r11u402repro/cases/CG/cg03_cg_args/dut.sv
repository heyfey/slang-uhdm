// § classCovergroupPropSilent402
class c;
  int v;
  covergroup g(int lo); coverpoint v { bins b = {[lo:10]}; } endgroup
  function new(); g = new(2); endfunction
endclass
module top; c o; endmodule
