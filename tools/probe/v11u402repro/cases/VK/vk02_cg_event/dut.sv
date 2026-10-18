// § classCovergroupPropSilent402
class c;
  bit [3:0] a;
  event ev;
  covergroup cg @(ev);
    cp: coverpoint a { bins lo = {[0:7]}; }
  endgroup
  int after;
endclass
module top;
endmodule
