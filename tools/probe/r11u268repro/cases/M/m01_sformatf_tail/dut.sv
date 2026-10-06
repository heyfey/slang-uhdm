// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
class c;
  function string u(); return "x"; endfunction
  virtual function string h();
    return $sformatf("%s %s",
       u(), `VS);
  endfunction
endclass
module top; endmodule
