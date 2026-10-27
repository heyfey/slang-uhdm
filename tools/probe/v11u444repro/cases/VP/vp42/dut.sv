// § progLocalDeclNets444
program prg;
typedef int q_t[$];
function automatic q_t f();
  q_t r;
  return r;
endfunction
initial begin q_t z; z = f(); end
endprogram
