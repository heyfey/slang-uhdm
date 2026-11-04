// § unitOobFuncOnDesign402
class base;
  virtual function int id(); return 0; endfunction
endclass
class der extends base;
  extern virtual function int id();
endclass
function int der::id(); return 1; endfunction
module top;
endmodule
