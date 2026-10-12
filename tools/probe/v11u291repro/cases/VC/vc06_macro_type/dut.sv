// § clsSpecDeclNameSpan291
`define BT box #(8)
class box #(int W = 8); int v; endclass
class hold;
  `BT p;
  function void f();
    `BT l;
    l = null;
  endfunction
endclass
module dut; hold h; initial h = new; endmodule
