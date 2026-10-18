// § unitOobFuncOnDesign402
class c;
int x;
extern function void set(int v);
endclass
function void c::set(int v); x = v; endfunction
module test;
  c o;
  initial begin o = new; o.set(3); end
endmodule
