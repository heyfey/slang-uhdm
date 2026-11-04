// § unitOobFuncOnDesign402
class c;
  extern function void ping();
endclass
function void c::ping(); $display("p"); endfunction
module top;
  c o;
  initial begin o = new; o.ping(); end
endmodule
