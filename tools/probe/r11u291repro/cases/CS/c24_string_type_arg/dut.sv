// § clsSpecDeclNameSpan291
class reg_c #(type T = int); endclass
class hold;
  reg_c #(string) r;
  function void f();
    reg_c #(bit [2:0]) l;
    l = null;
  endfunction
endclass
module dut; hold h; initial h = new; endmodule
