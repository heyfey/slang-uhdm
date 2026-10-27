// § progLocalDeclNets444
program prg;
typedef int q_t[$];
function automatic int f();
  int r;
  return r;
endfunction
function automatic q_t g();
  int k;
  q_t r;
  return r;
endfunction
initial begin int y; y = f(); end
endprogram
