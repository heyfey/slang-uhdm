package p;
class c;
  extern function void report();
endclass
function void c::report();
  $display(ver);
endfunction
string ver = "x";
endpackage
module top; endmodule
