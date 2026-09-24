// § aliasCloneTakesTargetFile137
// case al02: an unpacked-array alias of a packed union typedef in a module
module top();
  typedef union packed { logic [1:0] x; logic [1:0] y; } u_t;
  typedef u_t ua[4];
  ua v;
endmodule
