// § classCovergroupPropSilent402
module top;
  bit [3:0] a;
  covergroup mcg;
    coverpoint a;
  endgroup
  class c;
    int x;
  endclass
  mcg inst = new;
endmodule
