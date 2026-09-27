package p;
string values[$];
class c;
  extern function int report();
endclass
function int c::report();
  if (values.size() > 0) return 1;
  return 0;
endfunction
endpackage
module top; endmodule
